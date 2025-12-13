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
              image_pull_policy = "Always"
              
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
        "DATABASE" = "postgresql"
        "DB_NAME" = var.db_name
        "DB_PASSWORD" = var.db_password
        "DB_USER" = var.db_username
        "DB_HOST" = var.db_host
        "DB_PORT" = var.db_port
        "AWS_ACCESS_KEY_ID" = var.aws_access_key_id
        "AWS_SECRET_ACCESS_KEY" = var.aws_secret_access_key
        "AWS_DEFAULT_REGION_NAME" = var.aws_default_region_name
        "AWS_SES_REGION_NAME" = var.aws_ses_region_name
        "AWS_SES_REGION_ENDPOINT" = var.aws_ses_region_endpoint
        "DEFAULT_FROM_EMAIL" = var.default_from_email
        "USE_S3" = var.use_s3
        "AWS_STORAGE_BUCKET_NAME" = var.aws_storage_bucket_name
        "AWS_S3_REGION_NAME" = var.aws_s3_region_name
    }
}
