variable "node_container_image" { default = "xmtp/xmtpd:latest" }
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
