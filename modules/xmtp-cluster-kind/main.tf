locals {
  node_pool_label_key     = "node-pool"
  system_node_pool        = "xmtp-system"
  nodes_node_pool         = "xmtp-nodes"
  ingress_class_name      = "traefik"
  cluster_http_node_port  = 32080
  cluster_https_node_port = 32443
  hostnames               = ["localhost", "xmtp.local"]
  node_api_http_port      = 5001

  name = "${var.name_prefix}-${random_string.name_suffix.result}"

  chat_app_hostnames   = [for hostname in local.hostnames : "chat.${hostname}"]
  grafana_hostnames    = [for hostname in local.hostnames : "grafana.${hostname}"]
  jaeger_hostnames     = [for hostname in local.hostnames : "jaeger.${hostname}"]
  prometheus_hostnames = [for hostname in local.hostnames : "prometheus.${hostname}"]
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
  node_pool_label_key      = local.node_pool_label_key
  node_pool                = local.system_node_pool
  ingress_class_name       = local.ingress_class_name
  wait_for_ready           = false
  enable_chat_app          = var.enable_chat_app
  enable_monitoring        = var.enable_monitoring
  public_api_url           = "http://${local.hostnames[0]}"
  chat_app_hostnames       = local.chat_app_hostnames
  grafana_hostnames        = local.grafana_hostnames
  jaeger_hostnames         = local.jaeger_hostnames
  prometheus_hostnames     = local.prometheus_hostnames
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
  container_storage_request = "1Gi"
  container_cpu_request     = "10m"
  debug                     = true
  wait_for_ready            = false
  one_instance_per_k8s_node = false
}
