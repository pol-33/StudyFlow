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