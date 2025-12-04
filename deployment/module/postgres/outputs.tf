output "instance-name" {
  value = var.instance-name
}

output "database-host" {
  value = local.db-ip
}

output "database-port" {
  value = var.database-port
}

output "database-url" {
  value = local.db-url
}