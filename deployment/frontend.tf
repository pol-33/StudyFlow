module "frontend" {
  source            = "./module/frontend"
  namespace         = kubernetes_namespace.ns.metadata.0.name
  instance_name     = "frontend"
  image_name        = "${var.image_name}-frontend"
  vite_api_base_url = var.vite_api_base_url
  depends_on        = [module.backend]
}
