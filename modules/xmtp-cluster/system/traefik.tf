resource "kubernetes_service" "traefik" {
  wait_for_load_balancer = var.ingress_service_type == "LoadBalancer"
  metadata {
    name      = "traefik"
    namespace = local.namespace
    labels = {
      "app.kubernetes.io/name" = "traefik"
    }
    annotations = {}
  }
  spec {
    type = var.ingress_service_type
    selector = {
      "app.kubernetes.io/instance" = "traefik-${local.namespace}"
      "app.kubernetes.io/name"     = "traefik"
    }
    port {
      name        = "web"
      port        = 80
      protocol    = "TCP"
      target_port = "web"
      node_port   = var.cluster_http_node_port
    }
    port {
      name        = "websecure"
      port        = 443
      protocol    = "TCP"
      target_port = "websecure"
      node_port   = var.cluster_https_node_port
    }
  }
}

resource "helm_release" "traefik" {
  name       = "traefik"
  namespace  = local.namespace
  repository = "https://traefik.github.io/charts"
  version    = "21.1.0"
  chart      = "traefik"
  values = [
    <<EOF
      service:
        enabled: false
        type: ${var.ingress_service_type}
        annotations: ${yamlencode(var.ingress_service_annotations)}
      nodeSelector:
        ${var.node_pool_label_key}: ${var.node_pool}
      providers:
        kubernetesCRD:
          ingressClass: ${var.ingress_class_name}
        kubernetesIngress:
          ingressClass: ${var.ingress_class_name}
          publishedService:
            enabled: true
    EOF
  ]
}
