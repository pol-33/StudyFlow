resource "kubernetes_ingress_v1" "app" {
  metadata {
    name      = "app-ingress"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class"                           = "nginx"
      "nginx.ingress.kubernetes.io/enable-cors"              = "true"
      "nginx.ingress.kubernetes.io/cors-allow-origin"        = "*"
      "nginx.ingress.kubernetes.io/cors-allow-methods"       = "GET, POST, PUT, DELETE, OPTIONS"
      "nginx.ingress.kubernetes.io/cors-allow-headers"       = "DNT,User-Agent,Authorization,Content-Type,Accept,Origin,Referer,Accept-Encoding"
      "nginx.ingress.kubernetes.io/ssl-redirect"             = "false"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
          http {
            path {
              path      = "/"
              path_type = "Prefix"
              backend {
                service {
                  name = kubernetes_service.frontend-service.metadata[0].name
                  port {
                    number = 5173
                  }
                }
              }
            }

        path {
          path      = "/api"
          path_type = "Prefix"
          backend {
            service {
              name = var.backend_service_name
              port {
                number = 8000
              }
            }
          }
        }
      }
    }

    dynamic "tls" {
      for_each = var.enable_tls ? [1] : []
      content {
        secret_name = var.tls_secret_name
        hosts       = [var.ingress_host]
      }
    }
  }
}
