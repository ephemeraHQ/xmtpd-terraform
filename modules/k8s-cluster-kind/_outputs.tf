output "cluster_name" {
  value = kind_cluster.cluster.name
}

output "kubeconfig_path" {
  value = kind_cluster.cluster.kubeconfig_path
}
