module "postgres" {
  depends_on       = [kubernetes_config_map.postgres-initdb-config]
  source           = "./module/postgres"
  namespace        = kubernetes_namespace.ns.metadata.0.name
  instance-name    = "postgres"
  database-port    = 5432
  init-sql-configs = ["postgres-initdb-config"]
}

resource "kubernetes_config_map" "postgres-initdb-config" {
  metadata {
    name      = "postgres-initdb-config"
    namespace = kubernetes_namespace.ns.metadata.0.name
  }
  data = {
    "postgres-initdb-config.sql" = <<-EOT
        CREATE USER ${var.db_username} WITH ENCRYPTED PASSWORD '${var.db_password}' SUPERUSER;
        CREATE DATABASE ${var.db_name};
        \c ${var.db_name} ${var.db_username}

      EOT
  }
}
