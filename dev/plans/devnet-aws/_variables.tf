variable "region" {}
variable "availability_zones" { type = list(string) }
variable "hostnames" { type = list(string) }
variable "node_container_image" { default = "xmtp/xmtpd:latest" }
variable "chat_app_container_image" { default = "xmtp-labs/xmtp-inbox-web:latest" }
variable "kubernetes_version" { default = "1.26" }
variable "enable_chat_app" { default = true }
variable "enable_monitoring" { default = true }
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
variable "cloudflare_api_token" { sensitive = true }
variable "cloudflare_zone_id" {}
variable "datadog_api_key" {
  default   = ""
  sensitive = true
}
variable "datadog_cluster_name" { default = "" }
