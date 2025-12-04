variable "instance_name" {
  description = "Name for the backend instance, must be unique for each backend instance"
}

variable "namespace" {
  description = "kubernetes namespace where the backend instance is deployed"
}

variable "image_name" {
  description = "Name of the backend docker image"
}