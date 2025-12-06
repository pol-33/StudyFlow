resource "kubernetes_deployment" "postgres" {
  metadata {
    name      = local.app-name
    namespace = var.namespace
    labels = {
      App = local.app-name
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = local.app-name
      }
    }
    template {
      metadata {
        labels = {
          App = local.app-name
        }
      }
      spec {
        container {
          image = local.pg-image
          name  = local.app-name

          env_from {
            config_map_ref {
              name = kubernetes_config_map.postgres-env.metadata[0].name
            }
          }
          port {
            container_port = 5432
            name           = "postgres-port"
          }

          dynamic "volume_mount" {
            for_each = toset(var.init-sql-configs)
            content {
              mount_path = "/docker-entrypoint-initdb.d/${volume_mount.value}.sql"
              name       = volume_mount.value
              sub_path   = "${volume_mount.value}.sql"
              read_only  = true
            }
          }
          liveness_probe {
            exec {
              command = ["pg_isready", "-U", "postgres"]
            }
            failure_threshold = 10
            period_seconds    = 5
            timeout_seconds   = 30
          }
        }

        dynamic "volume" {
          for_each = toset(var.init-sql-configs)
          content {
            name = volume.value
            config_map {
              name = volume.value
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_config_map" "postgres-env" {
  metadata {
    name      = "${local.app-name}-env"
    namespace = var.namespace
  }

  data = {
    POSTGRES_USER     = "postgres"
    POSTGRES_PASSWORD = "postgres"
  }
}

resource "kubernetes_service" "pg-service" {
  metadata {
    name      = "${local.app-name}-service"
    namespace = var.namespace
  }
  spec {
    selector = {
      App = kubernetes_deployment.postgres.spec.0.template.0.metadata[0].labels.App
    }
    port {
      name        = "pg-port"
      port        = var.database-port
      target_port = var.database-port
    }
  }
}

locals {
    app-name = "${var.instance-name}-postgres"
    pg-image = "postgres:16.3-alpine3.20"
    db-ip = kubernetes_service.pg-service.spec.0.cluster_ip
    db-url = "postgresql://postgres:postgres@${local.db-ip}:${var.database-port}/postgres"
}