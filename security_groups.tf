resource "aws_security_group" "redis_security_group" {
  name        = "sg_${var.name}_${var.project}_${var.env}"
  description = "Security group that is needed for the ${var.name} servers"
  vpc_id      = data.aws_vpc.vpc.id

  tags = {
    Name        = "${var.project}-${var.env}-sg_${var.name}"
    Environment = var.env
    Project     = var.project
  }
}

resource "aws_security_group_rule" "redis_ingress" {
  count                    = length(var.allowed_security_groups)
  type                     = "ingress"
  from_port                = var.redis_port
  to_port                  = var.redis_port
  protocol                 = "tcp"
  source_security_group_id = element(var.allowed_security_groups, count.index)
  security_group_id        = aws_security_group.redis_security_group.id
}

resource "aws_security_group_rule" "redis_networks_ingress" {
  type              = "ingress"
  from_port         = var.redis_port
  to_port           = var.redis_port
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr
  security_group_id = aws_security_group.redis_security_group.id
}