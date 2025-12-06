resource "kubernetes_service" "backend-service" {
  metadata {
    name      = "${var.instance_name}-service"
    namespace = var.namespace
  }
  spec {
    selector = {
      App = kubernetes_deployment.backend.spec.0.template.0.metadata[0].labels.App
    }
    port {
      name        = "http"
      port        = 8000
      target_port = 8000
    }
    type = "ClusterIP"
  }
}
