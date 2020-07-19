module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  name               = "${var.environment}-ecs"
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

resource "aws_cloudwatch_log_group" "this" {
  name              = "simplyanalytics"
  retention_in_days = 1
}

resource "aws_ecs_task_definition" "this" {
  family = "${var.environment}-td"

  container_definitions = <<EOF
[
  {
    "name": "simplyanalytics",
    "image": "659424114285.dkr.ecr.eu-west-1.amazonaws.com/develop-ecr:latest",
    "cpu": 256,
    "memory": 512,
    "portMappings": [
        {
           "containerPort": 80,
           "hostPort": 80,
           "protocol": "tcp"
        }
     ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "eu-west-1",
        "awslogs-group": "simplyanalytics",
        "awslogs-stream-prefix": "simplyanalytics-ecs"
      }
    }
  }
]
EOF
}

resource "aws_ecs_service" "this" {
  name            = "simplyanalytics"
  cluster         = module.ecs.this_ecs_cluster_id
  task_definition = aws_ecs_task_definition.this.arn

  desired_count = 3

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "simplyanalytics"
    container_port   = 80
  }
}