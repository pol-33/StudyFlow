module "backend" {
    source = "./module/backend"
    instance_name = "backend"
    namespace = kubernetes_namespace.ns.metadata.0.name
    image_name = "${var.image_name}-backend"

    # ENV variables
    secret_key = var.secret_key
    debug = var.debug
    allowed_hosts = var.allowed_hosts
    cors_allowed_origins = var.cors_allowed_origins
    access_token_lifetime_minutes = var.access_token_lifetime_minutes
    refresh_token_lifetime_days = var.refresh_token_lifetime_days
}