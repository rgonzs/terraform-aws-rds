variable "tags" {
  description = "Tags to be added to resources"
  nullable    = true
  type        = map(string)
}

variable "bucket_prefix" {
  description = "Bucket prefix to be created"
  nullable    = false
  type        = string
}
