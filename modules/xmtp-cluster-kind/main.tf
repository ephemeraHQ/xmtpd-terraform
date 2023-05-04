locals {
  node_pool_label_key     = "node-pool"
  system_node_pool        = "xmtp-system"
  nodes_node_pool         = "xmtp-nodes"
  ingress_class_name      = "traefik"
  cluster_http_node_port  = 32080
  cluster_https_node_port = 32443
  hostnames               = ["localhost", "xmtp.local"]
  node_api_http_port      = 5001
  node_admin_port         = 8009
  e2e_admin_port          = 8010
  topic_reaper_period     = "2m"

  name = "${var.name_prefix}-${random_string.name_suffix.result}"

  node_hostnames_internal = [for node in var.nodes : "${node.name}.xmtp-nodes"]
  chat_app_hostnames      = [for hostname in local.hostnames : "chat.${hostname}"]
  grafana_hostnames       = [for hostname in local.hostnames : "grafana.${hostname}"]
  prometheus_hostnames    = [for hostname in local.hostnames : "prometheus.${hostname}"]
}

resource "random_string" "name_suffix" {
  length  = 5
  special = false
  upper   = false
}

module "k8s" {
  source = "./k8s"

  name            = local.name
  kubeconfig_path = startswith(var.kubeconfig_path, "/") ? var.kubeconfig_path : abspath(var.kubeconfig_path)
  nodes = concat(
    [{
      labels = {
        (local.node_pool_label_key) = local.system_node_pool
        "ingress-ready"             = "true"
      }
      extra_port_mappings = {
        (local.cluster_http_node_port)  = var.ingress_http_port
        (local.cluster_https_node_port) = var.ingress_https_port
      }
    }],
    [for i in range(var.num_xmtp_node_pool_nodes) : {
      labels = {
        (local.node_pool_label_key) = local.nodes_node_pool
      }
    }]
  )
}

module "system" {
  source     = "../xmtp-cluster/system"
  depends_on = [module.k8s]

  namespace               = "xmtp-system"
  node_pool_label_key     = local.node_pool_label_key
  node_pool               = local.system_node_pool
  cluster_http_node_port  = local.cluster_http_node_port
  cluster_https_node_port = local.cluster_https_node_port
  ingress_class_name      = local.ingress_class_name
  ingress_service_type    = "NodePort"
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
  public_api_url           = "http://${local.hostnames[0]}"
  node_container_port      = local.node_api_http_port
  node_hostnames_internal  = local.node_hostnames_internal
  chat_app_hostnames       = local.chat_app_hostnames
  grafana_hostnames        = local.grafana_hostnames
  prometheus_hostnames     = local.prometheus_hostnames
  e2e_replicas             = var.e2e_replicas
  e2e_delay                = var.e2e_delay
  e2e_admin_port           = local.e2e_admin_port
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
  hostnames                 = local.hostnames
  node_api_http_port        = local.node_api_http_port
  storage_class_name        = "standard"
  container_storage_request = var.node_container_storage_request
  container_cpu_request     = var.node_container_cpu_request
  container_memory_request  = var.node_container_memory_request
  container_cpu_limit       = var.node_container_cpu_limit
  container_memory_limit    = var.node_container_memory_limit
  debug                     = true
  wait_for_ready            = false
  one_instance_per_k8s_node = false
  admin_port                = local.node_admin_port
  topic_reaper_period       = local.topic_reaper_period
}
