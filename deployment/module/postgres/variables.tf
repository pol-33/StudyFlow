variable "instance-name" {
  description = "Name for the Postgres instance, must be unique for each postgres instances"
}

variable "database-port" {
  default = 5432
  description = "Port number for the Postgres instance"
}

variable "init-sql-configs" {
  description = "Name of config maps with init sql scripts"
  default     = []
}

variable "namespace" {
  description = "kubernetes namespace where the PG instance is deployed"
}