resource "kubernetes_config_map" "xmtp-dashboards" {
  count      = var.enable_monitoring ? 1 : 0
  depends_on = [kubernetes_namespace.tools]
  metadata {
    name      = "xmtp-dashboards"
    namespace = var.namespace
  }
  data = {
    "xmtp-network-api.json" = file("${path.module}/grafana/dashboards/xmtp-network-api.json")
  }
}

resource "helm_release" "grafana" {
  count      = var.enable_monitoring ? 1 : 0
  wait       = var.wait_for_ready
  name       = "grafana"
  namespace  = var.namespace
  repository = "https://grafana.github.io/helm-charts"
  version    = "6.51.2"
  chart      = "grafana"
  values = [
    <<EOF
      nodeSelector:
        node-pool: ${var.node_pool}
      persistence:
        enabled: false
      ingress:
        enabled: true
        hosts: ${jsonencode(var.grafana_hostnames)}
      grafana.ini:
        auth.anonymous:
          enabled: true
          org_name: "Main Org."
          # Role for unauthenticated users, other valid values are `Editor` and `Admin`
          org_role: "Admin"
      datasources:
        datasources.yaml:
          apiVersion: 1
          datasources:
          - name: Prometheus
            uid: xmtpd-metrics
            type: prometheus
            url: http://${local.prometheus_server_endpoint}
            editable: true
            isDefault: true
            jsonData:
              exemplarTraceIdDestinations:
                - datasourceUid: xmtpd-traces
                  name: trace_id
                - url: ${local.jaegar_public_url}/jaeger/ui/trace/$${__value.raw}
                  name: trace_id
                  urlDisplayLabel: View in Jaeger UI
          - name: Jaeger
            uid: xmtpd-traces
            type: jaeger
            url: http://${local.jaeger_query_endpoint}/jaeger/ui
            editable: true
            isDefault: false
      ${indent(6, file("${path.module}/grafana/dashboards-helm-values.yaml"))}
    EOF
  ]
}
