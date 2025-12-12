resource "kubernetes_service" "frontend-service" {
  metadata {
    name      = "${var.instance_name}-service"
    namespace = var.namespace
  }
  spec {
    selector = {
      App = kubernetes_deployment.frontend.spec.0.template.0.metadata[0].labels.App
    }
    port {
      name        = "http"
      port        = 5173
      target_port = 5173
    }
    type = "ClusterIP"
  }
}
