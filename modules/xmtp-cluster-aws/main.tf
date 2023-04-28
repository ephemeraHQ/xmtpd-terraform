locals {
  node_pool_label_key = "node-pool"
  system_node_pool    = "xmtp-system"
  nodes_node_pool     = "xmtp-nodes"
  ingress_class_name  = "traefik"
  node_api_http_port  = 5001
  node_admin_port     = 8009

  name = "${var.name_prefix}-${random_string.name_suffix.result}"

  node_hostnames_internal = [for node in var.nodes : "${node.name}.xmtp-nodes"]
  node_hostnames          = flatten([for node in var.nodes : [for hostname in var.hostnames : "${node.name}.${hostname}"]])
  chat_app_hostnames      = [for hostname in var.hostnames : "chat.${hostname}"]
  grafana_hostnames       = [for hostname in var.hostnames : "grafana.${hostname}"]
  prometheus_hostnames    = [for hostname in var.hostnames : "prometheus.${hostname}"]
}

data "aws_caller_identity" "current" {}

resource "random_string" "name_suffix" {
  length  = 5
  special = false
  upper   = false
}

module "k8s" {
  source = "./k8s"

  name                         = local.name
  region                       = var.region
  availability_zones           = var.availability_zones
  vpc_cidr_block               = var.vpc_cidr_block
  kubernetes_version           = var.kubernetes_version
  enabled_cluster_log_types    = var.enabled_cluster_log_types
  cluster_log_retention_period = var.cluster_log_retention_period
  map_additional_iam_users     = var.eks_map_additional_iam_users

  node_pools = [
    {
      name           = local.system_node_pool
      instance_types = [var.system_node_pool_instance_type]
      desired_size   = var.system_node_pool_desired_size
      labels = {
        (local.node_pool_label_key) = local.system_node_pool
      }
    },
    {
      name           = local.nodes_node_pool
      instance_types = [var.nodes_node_pool_instance_type]
      desired_size   = var.nodes_node_pool_desired_size
      labels = {
        (local.node_pool_label_key) = local.nodes_node_pool
      }
    }
  ]
}

module "system" {
  source     = "../xmtp-cluster/system"
  depends_on = [module.k8s]

  namespace            = "xmtp-system"
  node_pool_label_key  = local.node_pool_label_key
  node_pool            = local.system_node_pool
  ingress_class_name   = local.ingress_class_name
  ingress_service_type = "LoadBalancer"
}

module "tools" {
  source     = "../xmtp-cluster/tools"
  depends_on = [module.system]

  namespace                = "xmtp-tools"
  chat_app_container_image = var.chat_app_container_image
  e2e_container_image      = var.e2e_container_image
  node_pool_label_key      = local.node_pool_label_key
  node_pool                = local.system_node_pool
  ingress_class_name       = local.ingress_class_name
  wait_for_ready           = false
  enable_chat_app          = var.enable_chat_app
  enable_monitoring        = var.enable_monitoring
  enable_e2e               = var.enable_e2e
  public_api_url           = "https://${var.hostnames[0]}"
  node_container_port      = local.node_api_http_port
  node_hostnames_internal  = local.node_hostnames_internal
  chat_app_hostnames       = local.chat_app_hostnames
  grafana_hostnames        = local.grafana_hostnames
  prometheus_hostnames     = local.prometheus_hostnames
  datadog_api_key          = var.datadog_api_key
  datadog_cluster_name     = var.datadog_cluster_name
  e2e_replicas             = var.e2e_replicas
}

module "nodes" {
  source     = "../xmtp-cluster/nodes"
  depends_on = [module.system]

  namespace                 = "xmtp-nodes"
  container_image           = var.node_container_image
  node_pool_label_key       = local.node_pool_label_key
  node_pool                 = local.nodes_node_pool
  nodes                     = var.nodes
  node_keys                 = var.node_keys
  ingress_class_name        = local.ingress_class_name
  hostnames                 = var.hostnames
  node_api_http_port        = local.node_api_http_port
  storage_class_name        = "gp2"
  container_storage_request = var.container_storage_request
  container_cpu_request     = var.container_cpu_request
  container_memory_request  = var.container_memory_request
  container_cpu_limit       = var.container_cpu_limit
  container_memory_limit    = var.container_memory_limit
  debug                     = true
  wait_for_ready            = false
  one_instance_per_k8s_node = false
  admin_port                = local.node_admin_port
}
