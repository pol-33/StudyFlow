variable "instance_name" {
  description = "Name for the backend instance, must be unique for each backend instance"
}

variable "namespace" {
  description = "kubernetes namespace where the backend instance is deployed"
}

variable "image_name" {
  description = "Name of the backend docker image"
}

variable "secret_key" {
  description = "ENV SECRET_KEY for the backend instance"
}

variable "debug" {
  description = "ENV DEBUG for the backend instance"
}

variable "allowed_hosts" {
  description = "ENV ALLOWED_HOSTS for the backend instance"
}

variable "cors_allowed_origins" {
  description = "ENV CORS_ALLOWED_ORIGINS for the backend instance"
}

variable "access_token_lifetime_minutes" {
  description = "ENV ACCESS_TOKEN_LIFETIME_MINUTES for the backend instance"
}

variable "refresh_token_lifetime_days" {
  description = "ENV REFRESH_TOKEN_LIFETIME_DAYS for the backend instance"
}

variable "db_name" {
  description = "ENV DB_NAME for the backend instance"
}

variable "db_password" {
  description = "ENV DB_PASSWORD for the backend instance"
}

variable "db_username" {
  description = "ENV DB_USERNAME for the backend instance"
}

variable "db_host" {
  description = "ENV DB_HOST for the backend instance"
}

variable "db_port" {
  description = "ENV DB_PORT for the backend instance"
}

variable "aws_access_key_id" {
  description = "ENV AWS_ACCESS_KEY_ID for the backend instance"
}

variable "aws_secret_access_key" {
  description = "ENV AWS_SECRET_ACCESS_KEY for the backend instance"
}

variable "aws_default_region_name" {
  description = "ENV AWS_DEFAULT_REGION_NAME for the backend instance"
}

variable "aws_ses_region_name" {
  description = "ENV AWS_SES_REGION_NAME for the backend instance"
}

variable "aws_ses_region_endpoint" {
  description = "ENV AWS_SES_REGION_ENDPOINT for the backend instance"
}

variable "default_from_email" {
  description = "ENV DEFAULT_FROM_EMAIL for the backend instance"
}

variable "use_s3" {
  description = "ENV USE_S3 for the backend instance"
}

variable "aws_storage_bucket_name" {
  description = "ENV AWS_STORAGE_BUCKET_NAME for the backend instance"
}

variable "aws_s3_region_name" {
  description = "ENV AWS_S3_REGION_NAME for the backend instance"
}