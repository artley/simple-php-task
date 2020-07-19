resource aws_dynamodb_table this {
  name           = "simplyanalytics-task1-${var.environment}-tfstate"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}