variable "instance_name" {
  description = "Name for the frontend instance, must be unique for each frontend instance"
}

variable "namespace" {
  description = "kubernetes namespace where the frontend instance is deployed"
}

variable "image_name" {
  description = "Name of the frontend docker image"
}

variable "vite_api_base_url" {
  description = "The base URL for the backend API, used by the frontend to make requests."
}
