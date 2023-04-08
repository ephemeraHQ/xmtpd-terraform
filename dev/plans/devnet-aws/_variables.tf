variable "node_container_image" { default = "xmtpdev/xmtpd:dev" }
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
