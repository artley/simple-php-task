resource "aws_ecr_repository" "this" {
  name                 = "${var.environment}-ecr"
}