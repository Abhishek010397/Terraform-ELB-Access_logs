module "s3_bucket_elb_logs" {
  source                      = "./module/s3"
  ENV                         = var.ENV
  bucket_name                 = var.bucket_name
  account_number              = var.account_number
  bucket_rule_id              = var.bucket_rule_id
  bucket_rule_expiration_days = var.bucket_rule_expiration_days
  bucket_policy_resource      = var.bucket_policy_resource
  bucket_rule_prefix          = var.bucket_rule_prefix
}
