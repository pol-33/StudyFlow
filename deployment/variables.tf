variable "db_name" {
  default     = "studyflow"
  description = "The name of the backend database."
}

variable "db_password" {
  default     = "backend"
  description = "The password for the backend database user."
}

variable "db_username" {
  default     = "backend"
  description = "The username for the backend database user."
}

variable "db_host" {
  type        = string
  default     = ""
  description = "The host for the backend database."
}

variable "db_port" {
  type        = string
  default     = "5432"
  description = "The port for the backend database."
}

variable "image_name" {
  default     = "770404291990.dkr.ecr.eu-south-2.amazonaws.com/studyflow"
  description = "The name of the docker images"
}

variable "secret_key" {
  default     = "backend"
  description = "The secret key for the backend instance."
}

variable "debug" {
  default     = "True"
  description = "The debug mode for the backend instance."
}

variable "allowed_hosts" {
  default     = "*"
  description = "The allowed hosts for the backend instance."
}

variable "cors_allowed_origins" {
  default     = "http://localhost:5173,http://127.0.0.1:5173"
  description = "The CORS allowed origins for the backend instance."
}

variable "access_token_lifetime_minutes" {
  default     = "30"
  description = "The access token lifetime in minutes for the backend instance."
}

variable "refresh_token_lifetime_days" {
  default     = "7"
  description = "The refresh token lifetime in days for the backend instance."
}

variable "vite_api_base_url" {
  default     = "http://a2afff947f9db45bab37ec355815d8fa-41931144.eu-south-2.elb.amazonaws.com"
  description = "The base URL for the backend API, used by the frontend to make requests."
}

variable "aws_access_key_id" {
  default     = "your_access_key"
  description = "The AWS access key ID for the backend instance."
}

variable "aws_secret_access_key" {
  default     = "your_secret_key"
  description = "The AWS secret access key for the backend instance."
}

variable "aws_default_region_name" {
  default     = "eu-west-2"
  description = "The AWS default region name for the backend instance."
}

variable "aws_ses_region_name" {
  default     = "eu-west-3"
  description = "The AWS SES region name for the backend instance."
}

variable "aws_ses_region_endpoint" {
  default     = "email.eu-west-3.amazonaws.com"
  description = "The AWS SES region endpoint for the backend instance."
}

variable "default_from_email" {
  default     = "StudyFlow <noreply@polplana.work>"
  description = "The default from email for the backend instance."
}

variable "use_s3" {
  default     = "False"
  description = "The use S3 for the backend instance."
}

variable "aws_storage_bucket_name" {
  default     = "your-s3-bucket-name"
  description = "The AWS S3 bucket name for the backend instance."
}

variable "aws_s3_region_name" {
  default     = "eu-south-2"
  description = "The AWS S3 region name for the backend instance."
}

variable "aws_region" {
  default     = "eu-south-2"
  description = "AWS region for provider configuration."
}

variable "eks_cluster_name" {
  default     = "studyflow"
  description = "EKS cluster name to target for Kubernetes provider."
}

variable "kubernetes_namespace" {
  default     = "studyflow"
  description = "Kubernetes namespace to create/use in the target cluster."
}
