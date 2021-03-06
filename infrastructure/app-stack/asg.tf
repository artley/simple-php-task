data "aws_ami" "amazon_linux_ecs" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/templates/user-data.sh")

  vars = {
    cluster_name = "${var.environment}-ecs"
  }
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 3.0"

  name = "ec2-cluster"

  # Launch configuration
  lc_name = "${var.environment}-lc"

  image_id        = data.aws_ami.amazon_linux_ecs.id
  instance_type   = "t2.micro"
  key_name        = var.environment
  security_groups = [module.ec2-sg.this_security_group_id]
  iam_instance_profile = aws_iam_instance_profile.this.id
  user_data            = data.template_file.user_data.rendered

  ebs_block_device = [
    {
      device_name           = "/dev/xvdz"
      volume_type           = "gp2"
      volume_size           = "10"
      delete_on_termination = true
    },
  ]

  root_block_device = [
    {
      volume_size = "10"
      volume_type = "gp2"
    },
  ]

  # Auto scaling group
  asg_name                    = "${var.environment}-asg"
  vpc_zone_identifier         = module.vpc.public_subnets
  associate_public_ip_address = true
  health_check_type           = "EC2"
  min_size                    = 0
  max_size                    = 3
  desired_capacity            = 3
  wait_for_capacity_timeout   = 0

  tags = [
    {
      key                 = "Environment"
      value               = var.environment
      propagate_at_launch = true
    },
  ]
}

module "ec2-sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.environment}-ec2-sg"
  description = "Security group for the EC2 instances"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.alb-sg.this_security_group_id
    },
    {
      rule                     = "all-all"
      source_security_group_id = module.vpc.default_security_group_id
    }
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  #Not great, never in production
  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

}

resource "aws_iam_role" "this" {
  name = "${var.environment}_ecs_instance_role"
  path = "/ecs/"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com", "autoscaling.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.environment}_ecs_instance_profile"
  role = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_role" {
  role       = aws_iam_role.this.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_cloudwatch_role" {
  role       = aws_iam_role.this.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}