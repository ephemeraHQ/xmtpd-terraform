locals {
  prometheus_server_endpoint = "prometheus-server:80"
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
          kubernetes_sd_configs:
          - role: pod
            selectors:
            - role: pod
              label: "app.kubernetes.io/part-of=xmtp-nodes"
          relabel_configs:
          - source_labels: [__meta_kubernetes_pod_container_port_name]
            action: keep
            regex: admin
          - source_labels: [__meta_kubernetes_namespace]
            action: replace
            target_label: kube_namespace
          - source_labels: [__meta_kubernetes_pod_label_app_kubernetes_io_name]
            action: replace
            target_label: kube_app_name
          - source_labels: [__meta_kubernetes_pod_label_app_kubernetes_io_part_of]
            action: replace
            target_label: kube_app_part_of
    EOF
  ]
}
