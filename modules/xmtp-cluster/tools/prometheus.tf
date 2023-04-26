locals {
  prometheus_server_endpoint = "prometheus-server:80"
  prometheus_server_url      = "http://${local.prometheus_server_endpoint}"
  node_admin_endpoints       = [for node in var.node_hostnames_internal : "${node}:${var.node_admin_port}"]
}

resource "helm_release" "prometheus" {
  count      = var.enable_monitoring ? 1 : 0
  wait       = var.wait_for_ready
  name       = "prometheus"
  namespace  = local.namespace
  repository = "https://prometheus-community.github.io/helm-charts"
  version    = "19.7.2"
  chart      = "prometheus"
  values = [
    <<EOF
      server:
        nodeSelector:
          node-pool: ${var.node_pool}
        persistentVolume:
          enabled: false
        ingress:
          enabled: true
          hosts: ${jsonencode(var.prometheus_hostnames)}
        global:
          evaluation_interval: 30s
          scrape_interval: 10s
          scrape_timeout: 5s
      alertmanager:
        persistence:
          enabled: false
        nodeSelector:
          node-pool: ${var.node_pool}
      kube-state-metrics:
        nodeSelector:
          node-pool: ${var.node_pool}
      prometheus-pushgateway:
        nodeSelector:
          node-pool: ${var.node_pool}
      extraScrapeConfigs: |
        - job_name: xmtpd
          static_configs:
          - targets: ${jsonencode(local.node_admin_endpoints)}
    EOF
  ]
}
