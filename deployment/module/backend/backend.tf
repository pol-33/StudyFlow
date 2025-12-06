resource "kubernetes_deployment" "backend" {
    metadata {
        name      = "${var.instance_name}"
        namespace = var.namespace
        labels = {
            App = "${var.instance_name}"
        }
    }

    spec {
        replicas = 1
    
        selector {
          match_labels = {
            App = "${var.instance_name}"
          }
        }
        template {
          metadata {
            labels = {
              App = "${var.instance_name}"
            }
          }
          spec {
            container {
              image = "${var.image_name}:latest"
              name  = "${var.instance_name}-backend"
              image_pull_policy = "IfNotPresent"
              
              env_from {
                config_map_ref {
                  name = kubernetes_config_map.backend-config.metadata[0].name
                }
              }

              port {
                container_port = 8000
                name = "http"
                protocol = "TCP"
              }
            }
          }
        }
    }
}

resource "kubernetes_config_map" "backend-config" {
    metadata {
        name      = "${var.instance_name}-backend-config"
        namespace = var.namespace
    }  

    data = {
        "SECRET_KEY" = var.secret_key
        "DEBUG" = var.debug
        "ALLOWED_HOSTS" = var.allowed_hosts
        "CORS_ALLOWED_ORIGINS" = var.cors_allowed_origins
        "ACCESS_TOKEN_LIFETIME_MINUTES" = var.access_token_lifetime_minutes
        "REFRESH_TOKEN_LIFETIME_DAYS" = var.refresh_token_lifetime_days
    }
}
