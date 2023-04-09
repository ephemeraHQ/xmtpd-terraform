locals {
  postgres_name         = "${var.name}-db"
  postgres_service_name = "${local.postgres_name}-postgresql"
  postgres_password     = one(data.kubernetes_secret.postgres[*].data.postgres-password)
  postgres_dsn          = local.postgres_password != null ? "postgres://postgres:${local.postgres_password}@${local.postgres_service_name}:5432?sslmode=disable" : null
}

resource "helm_release" "postgres" {
  count = var.store_type == "postgres" ? 1 : 0

  name       = local.postgres_name
  namespace  = var.namespace
  repository = "https://charts.bitnami.com/bitnami"
  version    = "12.2.3"
  chart      = "postgresql"
}

data "kubernetes_secret" "postgres" {
  count      = var.store_type == "postgres" ? 1 : 0
  depends_on = [helm_release.postgres]
  metadata {
    name      = "${local.postgres_name}-postgresql"
    namespace = var.namespace
  }
}
