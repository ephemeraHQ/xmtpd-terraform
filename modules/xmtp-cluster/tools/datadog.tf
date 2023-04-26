resource "helm_release" "datadog-agent" {
  count   = var.datadog_api_key == "" ? 0 : 1
  wait    = var.wait_for_ready
  name    = "datadog-agent"
  version = "3.25.5"

  namespace  = local.namespace
  repository = "https://helm.datadoghq.com"
  chart      = "datadog"
  values = [
    # see https://github.com/DataDog/helm-charts/blob/main/charts/datadog/values.yaml
    <<-EOT
    registry: public.ecr.aws/datadog
    datadog:
      apiKey: ${var.datadog_api_key}
      clusterName: ${var.datadog_cluster_name}
      logs:
        enabled: true
        containerCollectAll: true
    EOT
  ]
}