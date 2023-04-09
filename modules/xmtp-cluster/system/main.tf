resource "kubernetes_namespace" "system" {
  metadata {
    name = var.namespace
  }
}

locals {
  namespace = kubernetes_namespace.system.metadata[0].name
}
