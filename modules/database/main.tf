resource "aws_kms_key" "rds_key" {
  description              = "KMS Key used to cipher objects"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = true
  deletion_window_in_days  = 7
  multi_region             = false
  tags                     = var.tags
}

resource "aws_kms_alias" "rds_key" {
  name          = "alias/rds_key"
  target_key_id = aws_kms_key.rds_key.key_id
}

resource "aws_rds_cluster" "aurora_postgresql" {
  cluster_identifier            = var.cluster_identifier
  engine                        = "aurora-postgresql"
  engine_mode                   = "provisioned"
  engine_version                = "16.2"
  database_name                 = var.database_name
  master_username               = var.master_username
  manage_master_user_password   = true
  master_user_secret_kms_key_id = aws_kms_key.rds_key.id
  storage_encrypted             = true
  tags                          = var.tags
  kms_key_id                    = aws_kms_alias.rds_key.arn
  skip_final_snapshot           = true
  db_subnet_group_name          = aws_db_subnet_group.aurora_subnetgroup.name

  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }
}

resource "aws_rds_cluster_instance" "aurora_postgresql" {
  cluster_identifier   = aws_rds_cluster.aurora_postgresql.id
  instance_class       = "db.serverless"
  engine               = aws_rds_cluster.aurora_postgresql.engine
  engine_version       = aws_rds_cluster.aurora_postgresql.engine_version
  tags                 = var.tags
  db_subnet_group_name = aws_db_subnet_group.aurora_subnetgroup.name
}

resource "aws_db_subnet_group" "aurora_subnetgroup" {
  name_prefix = var.cluster_identifier
  subnet_ids  = var.subnet_dbs
  tags        = var.tags
}
