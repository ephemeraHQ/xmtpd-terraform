output "k8s_cluster_name" {
  value = module.k8s.cluster_name
}

output "argocd_namespace" {
  value = module.system.namespace
}

output "argocd_hostnames" {
  value = module.system.argocd_hostnames
}

output "argocd_username" {
  value = module.system.argocd_username
}

output "argocd_password" {
  value     = module.system.argocd_password
  sensitive = true
}

output "nodes" {
  value = var.nodes
}
