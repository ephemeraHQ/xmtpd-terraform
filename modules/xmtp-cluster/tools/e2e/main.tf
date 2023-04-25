locals {
  labels = {
    "app.kubernetes.io/name" = var.name
  }
}

resource "kubernetes_deployment" "deployment" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = local.labels
  }
  spec {
    replicas = var.replicas
    selector {
      match_labels = local.labels
    }
    template {
      metadata {
        labels = local.labels
      }
      spec {
        node_selector = {
          (var.node_pool_label_key) = var.node_pool_label_value
        }
        container {
          name  = "main"
          image = var.container_image
          command = concat(
            ["xmtpd-e2e", "--continuous"],
            [for api_url in var.api_urls : "--api-url=${api_url}"]
          )
        }
      }
    }
  }
}
