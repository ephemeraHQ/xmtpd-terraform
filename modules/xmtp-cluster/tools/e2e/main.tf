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
        annotations = {
          "prometheus.io/scrape" = "true"
          "prometheus.io/path"   = "/metrics"
          "prometheus.io/port"   = var.admin_port
        }
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
            ["--admin-port=${var.admin_port}"],
            var.delay != "" ? ["--delay=${var.delay}"] : [],
            [for api_url in var.api_urls : "--api-url=${api_url}"],
          )
          port {
            name           = "admin"
            container_port = var.admin_port
          }
          readiness_probe {
            http_get {
              path = "/healthz"
              port = "admin"
            }
            success_threshold = 1
            failure_threshold = 3
            period_seconds    = 10
          }
        }
      }
    }
  }
}
