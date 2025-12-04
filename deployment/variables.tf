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