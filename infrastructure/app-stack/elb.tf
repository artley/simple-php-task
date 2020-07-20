resource "aws_lb" "this" {
  name = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets         = module.vpc.public_subnets
  security_groups = [module.alb-sg.this_security_group_id]

  tags = {
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "this" {
  name     = "${var.environment}-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  depends_on = [aws_lb.this]
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

module "alb-sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "${var.environment}-alb-sg"
  description = "Security group for the ALB"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
}