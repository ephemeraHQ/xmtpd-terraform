resource "kubernetes_namespace" "tools" {
  metadata {
    name = var.namespace
  }
}

locals {
  namespace = kubernetes_namespace.tools.metadata[0].name
}

module "chat-app" {
  source = "./chat-app"
  count  = var.enable_chat_app ? 1 : 0

  namespace             = local.namespace
  node_pool_label_key   = var.node_pool_label_key
  node_pool_label_value = var.node_pool
  api_url               = var.public_api_url
  hostnames             = var.chat_app_hostnames
  ingress_class_name    = var.ingress_class_name
  container_image       = var.chat_app_container_image
}

module "e2e" {
  source = "./e2e"
  count  = var.enable_e2e ? 1 : 0

  namespace             = local.namespace
  node_pool_label_key   = var.node_pool_label_key
  node_pool_label_value = var.node_pool
  api_urls              = [for hostname in var.node_hostnames_internal : "http://${hostname}:${var.node_container_port}"]
  container_image       = var.e2e_container_image
  replicas              = var.e2e_replicas
  delay                 = var.e2e_delay
  admin_port            = var.e2e_admin_port
}
