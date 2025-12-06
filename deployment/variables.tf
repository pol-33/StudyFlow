variable "db_password" {
  default = "backend"
  description = "The password for the backend database user."
}

variable "db_username" {
  default = "backend"
  description = "The username for the backend database user."
}

variable "image_name" {
    default = "2026_1-project-12_01_a"
    description = "The name of the docker images"
}

variable "secret_key" {
  default = "backend"
  description = "The secret key for the backend instance."
}

variable "debug" {
  default = "True"
  description = "The debug mode for the backend instance."
}

variable "allowed_hosts" {
  default = "*"
  description = "The allowed hosts for the backend instance."
}

variable "cors_allowed_origins" {
  default = "*"
  description = "The CORS allowed origins for the backend instance."
}

variable "access_token_lifetime_minutes" {
  default = "30"
  description = "The access token lifetime in minutes for the backend instance."
}

variable "refresh_token_lifetime_days" {
  default = "7"
  description = "The refresh token lifetime in days for the backend instance."
}

variable "vite_api_base_url" {
  default = "http://localhost"
  description = "The base URL for the backend API, used by the frontend to make requests."
}
