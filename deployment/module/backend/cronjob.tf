resource "kubernetes_cron_job_v1" "notification_cronjob" {
  metadata {
    name      = "${var.instance_name}-notifications"
    namespace = var.namespace
  }

  spec {
    schedule                      = "*/5 * * * *"  # Every 5 minutes
    concurrency_policy           = "Forbid"        # Don't run if previous still running
    successful_jobs_history_limit = 3
    failed_jobs_history_limit     = 3
    starting_deadline_seconds     = 60

    job_template {
      metadata {
        labels = {
          App = "${var.instance_name}-notifications"
        }
      }

      spec {
        ttl_seconds_after_finished = 300  # Clean up completed jobs after 5 min
        backoff_limit              = 1

        template {
          metadata {
            labels = {
              App = "${var.instance_name}-notifications"
            }
          }

          spec {
            restart_policy = "Never"

            container {
              name              = "notifications"
              image             = "${var.image_name}:latest"
              image_pull_policy = "Always"

              command = ["python", "manage.py", "send_due_notifications"]

              env_from {
                config_map_ref {
                  name = kubernetes_config_map.backend-config.metadata[0].name
                }
              }
            }
          }
        }
      }
    }
  }
}
