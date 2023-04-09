output "k8s_cluster_name" {
  value = module.k8s.cluster_name
}

output "nodes" {
  value = var.nodes
}
