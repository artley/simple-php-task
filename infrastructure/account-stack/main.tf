module s3 {
  source      = "./modules/s3"
  environment = var.environment
}

module dynamodb {
  source      = "./modules/dynamo"
  environment = var.environment
}