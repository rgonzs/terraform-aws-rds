variable "database_name" {
  type        = string
  description = "Database name to be used"
  nullable    = false
}

variable "cluster_identifier" {
  type        = string
  description = "Cluster identifier"
  nullable    = false
}

variable "master_username" {
  type        = string
  nullable    = false
  description = "Master user of db"
}

variable "subnet_dbs" {
  type        = set(string)
  nullable    = false
  description = "Subnet ids to be used"
}

variable "tags" {
  type     = map(string)
  nullable = true
  default  = null
}
