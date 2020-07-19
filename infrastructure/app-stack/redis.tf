resource "aws_elasticache_replication_group" "this" {
  automatic_failover_enabled    = true
  availability_zones            = module.vpc.azs
  replication_group_id          = "${var.environment}-redis-rg"
  replication_group_description = "Replication group for redis"
  node_type                     = "cache.t2.micro"
  number_cache_clusters         = 3
  engine_version                = "5.0.6"
  parameter_group_name          = "default.redis5.0"
  port                          = 6379
  security_group_ids            = [module.cache-sg.this_security_group_id]
  subnet_group_name             = aws_elasticache_subnet_group.this.name
}

module "cache-sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.environment}-db-sg"
  description = "Security group for the cache"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 6379
      to_port                  = 6379
      protocol                 = "tcp"
      description              = "EC2 to cache"
      source_security_group_id = module.ec2-sg.this_security_group_id
    }
  ]
}

resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.environment}-cache-subnet"
  subnet_ids = module.vpc.public_subnets
}