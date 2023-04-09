output "namespace" {
  value = kubernetes_namespace.system.metadata[0].name
}

output "ingress_public_hostname" {
  value = try(kubernetes_service.traefik.status[0].load_balancer[0].ingress[0].hostname, null)
}
