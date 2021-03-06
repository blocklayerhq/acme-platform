resource "random_password" "password" {
  length = 16
  special = true
  override_special = "_%@"
}

module "db" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 2.0"

  name                            = var.db_name
  engine                          = "aurora"
  engine_version                  = "5.6.10a"
  engine_mode                     = "serverless"
  
  username                        = "admin"
  password                        = random_password.password.result

  vpc_id                          = module.vpc.vpc_id
  subnets                         = module.vpc.private_subnets

  replica_count                   = 0
  replica_scale_enabled           = false
  instance_type                   = "db.t2.small"
  allowed_security_groups         = [aws_security_group.all_worker_mgmt.id]
  allowed_cidr_blocks             = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  storage_encrypted               = true
  apply_immediately               = true
  monitoring_interval             = 10

  db_parameter_group_name         = "default.aurora5.6"

  scaling_configuration = {
    auto_pause               = true
    max_capacity             = 256
    min_capacity             = 2
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }
}
