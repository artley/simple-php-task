module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"

  identifier = "${var.environment}-postgres"

  engine            = "postgres"
  engine_version    = "9.6.9"
  instance_class    = "db.t2.micro"
  allocated_storage = 20
  storage_encrypted = false

  name = "simplyanalytics"

  username = var.db_username
  password = var.db_password
  port     = "5432"

  vpc_security_group_ids = [module.db-sg.this_security_group_id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  backup_retention_period = 0

  subnet_ids = module.vpc.database_subnets

  family = "postgres9.6"
  major_engine_version = "9.6"

  tags = {
    Environment = var.environment
  }
}

module "db-sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.environment}-db-sg"
  description = "Security group for the DB instances"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "postgresql-tcp"
      source_security_group_id = module.ec2-sg.this_security_group_id
    }
  ]
}