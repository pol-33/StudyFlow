module "backend" {
  source        = "./module/backend"
  instance_name = "backend"
  namespace     = kubernetes_namespace.ns.metadata.0.name
  image_name    = "${var.image_name}-backend"
  #depends_on    = [module.postgres]

  # ENV variables
  secret_key                    = var.secret_key
  debug                         = var.debug
  allowed_hosts                 = var.allowed_hosts
  cors_allowed_origins          = var.cors_allowed_origins
  access_token_lifetime_minutes = var.access_token_lifetime_minutes
  refresh_token_lifetime_days   = var.refresh_token_lifetime_days

  # Database
  db_name     = var.db_name
  db_password = var.db_password
  db_username = var.db_username
  db_host     = var.db_host
  db_port     = var.db_port

  # AWS
  aws_access_key_id       = var.aws_access_key_id
  aws_secret_access_key   = var.aws_secret_access_key
  aws_default_region_name = var.aws_default_region_name
  aws_ses_region_name     = var.aws_ses_region_name
  aws_ses_region_endpoint = var.aws_ses_region_endpoint
  default_from_email      = var.default_from_email
  use_s3                  = var.use_s3
  aws_storage_bucket_name = var.aws_storage_bucket_name
  aws_s3_region_name      = var.aws_s3_region_name
}
