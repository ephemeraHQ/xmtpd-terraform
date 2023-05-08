variable "name_prefix" {}
variable "kubeconfig_path" { default = ".xmtp/kubeconfig.yaml" }
variable "node_container_image" {}
variable "chat_app_container_image" { default = "xmtplabs/xmtp-inbox-web:latest" }
variable "nodes" {
  type = list(object({
    name                 = string
    node_id              = string
    p2p_public_address   = string
    p2p_persistent_peers = list(string)
    store_type           = optional(string, "mem")
  }))
}
variable "node_keys" {
  type      = map(string)
  sensitive = true
}
variable "enable_chat_app" { default = true }
variable "enable_monitoring" { default = true }
variable "num_xmtp_node_pool_nodes" { default = 2 }
variable "ingress_http_port" {}
variable "ingress_https_port" {}
variable "enable_e2e" { default = true }
variable "e2e_container_image" { default = "xmtp/xmtpd-e2e:latest" }
variable "e2e_replicas" { default = 1 }
variable "e2e_delay" { default = "" }
variable "node_container_storage_request" { default = "1Gi" }
variable "node_container_cpu_request" { default = "100m" }
variable "node_container_memory_request" { default = "400Mi" }
variable "node_container_cpu_limit" { default = "1000m" }
variable "node_container_memory_limit" { default = "800Mi" }
variable "debug" { default = false }
