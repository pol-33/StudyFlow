resource "kubernetes_deployment" "backend" {
    metadata {
        name = "${var.instance_name}-backend"
        namespace = var.namespace
        labels = {
            App = "${var.instance_name}-backend"
        }
    }

    spec {
        replicas = 1
        selector {
          match_labels = {
            App = "${var.image_name}-backend"
          }
        }
        template {
          metadata {
            labels = {
              App = "${var.instance_name}-backend"
            }
          }
          spec {
            container {
              image = var.image_name
              name  = "${var.instance_name}-backend"
              image_pull_policy = "IfNotPresent"
              
              env_from {
                config_map_ref {
                  name = kubernetes_config_map.backend-config.metadata[0].name
                }
              }

              port {
                container_port = 8080
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
        name = "${var.instance_name}-backend-config"
        namespace = var.namespace
    }  
}