resource "helm_release" "metrics_server" {
  count      = var.enable_monitoring ? 1 : 0
  wait       = var.wait_for_ready
  name       = "metrics-server"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  version    = "3.8.3"
  chart      = "metrics-server"
  values = [
    <<EOF
      args:
        - --kubelet-insecure-tls
        - --kubelet-preferred-address-types=InternalIP
      nodeSelector:
        ${var.node_pool_label_key}: ${var.node_pool}
    EOF
  ]
}
