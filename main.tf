data "aws_vpc" "vpc" {
  id = var.vpc_id
}

locals {
  vpc_name = lookup(data.aws_vpc.vpc.tags, "Name", var.vpc_id)
  parameter_group_family = substr(var.redis_version, 0,1) < 6 ?  "redis${replace(var.redis_version, "/\\.[\\d]+$/", "")}": "redis${replace(var.redis_version, "/\\.[\\d]+$/", "")}.x"
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id          = "${var.project}-${var.env}-${var.name}"
  replication_group_description = "Redis cluster for ${var.project}-${var.env}-${var.name}"
  number_cache_clusters         = var.redis_clusters
  node_type                     = var.redis_node_type
  automatic_failover_enabled    = var.redis_failover
  auto_minor_version_upgrade    = var.auto_minor_version_upgrade
  availability_zones            = var.availability_zones
  multi_az_enabled              = var.multi_az_enabled
  engine                        = "redis"
  at_rest_encryption_enabled    = var.at_rest_encryption_enabled
  kms_key_id                    = var.kms_key_id
  transit_encryption_enabled    = var.transit_encryption_enabled
  auth_token                    = var.transit_encryption_enabled ? var.auth_token : null
  engine_version                = var.redis_version
  port                          = var.redis_port
  parameter_group_name          = var.parameter_group_name
  subnet_group_name             = aws_elasticache_subnet_group.redis_subnet_group.id
  security_group_names          = var.security_group_names
  security_group_ids            = [aws_security_group.redis_security_group.id]
  snapshot_arns                 = var.snapshot_arns
  snapshot_name                 = var.snapshot_name
  apply_immediately             = var.apply_immediately
  maintenance_window            = var.redis_maintenance_window
  notification_topic_arn        = var.notification_topic_arn
  snapshot_window               = var.redis_snapshot_window
  snapshot_retention_limit      = var.redis_snapshot_retention_limit
  tags = {
    Name        = "${var.project}-${var.env}-${var.name}"
    Environment = var.env
    Project     = var.name
  }
}

resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name        = "${var.project}-${var.env}-redis"
  description = "Our main group of subnets"
  subnet_ids  = var.subnets
}

