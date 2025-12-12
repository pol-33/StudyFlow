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

variable "ingress_host" {
  description = "Hostname for ingress routing"
  default     = "localhost"
}

variable "enable_tls" {
  description = "Enable TLS termination on ingress"
  default     = false
}

variable "tls_secret_name" {
  description = "TLS secret name for ingress"
  default     = "tls-secret"
}

variable "backend_service_name" {
  description = "Name of backend service for ingress routing"
  default     = "backend-service"
}
