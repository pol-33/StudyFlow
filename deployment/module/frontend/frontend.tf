resource "kubernetes_deployment" "frontend" {
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
              name  = "${var.instance_name}"
              image_pull_policy = "Always"

              env_from {
                config_map_ref {
                  name = kubernetes_config_map.frontend-config.metadata[0].name
                }
              }
              port {
                container_port = 5173
                name = "http"
                protocol = "TCP"
              }
            }
          }
        }
    }
}

resource "kubernetes_config_map" "frontend-config" {
  metadata {
    name      = "${var.instance_name}-frontend-config"
    namespace = var.namespace
  }

  data = {
    "VITE_API_BASE_URL" = var.vite_api_base_url
  }
}
