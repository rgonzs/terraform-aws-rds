module "network" {
  source     = "./modules/network"
  aws_region = "us-east-1"
}

module "storage" {
  source        = "./modules/storage"
  bucket_prefix = "bucket-test-demo"
  tags = {
    project = "demo-devsu-pichincha"
  }
}

module "database" {
  source             = "./modules/database"
  subnet_dbs         = module.network.subnets_db_ids
  master_username    = "pgadmin"
  cluster_identifier = "db-test-devsu"
  database_name      = "dbtest"
  tags = {
    project = "demo-devsu-pichincha"
  }
}
