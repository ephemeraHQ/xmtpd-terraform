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
