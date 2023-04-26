variable "name_prefix" {}

variable "region" {
  type        = string
  description = "AWS Region"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}

variable "vpc_cidr_block" {}

variable "kubernetes_version" {
  type        = string
  description = "Desired Kubernetes master version. If you do not specify a value, the latest available version is used"
}

variable "enabled_cluster_log_types" {
  type        = list(string)
  default     = []
  description = "A list of the desired control plane logging to enable. For more information, see https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html. Possible values [`api`, `audit`, `authenticator`, `controllerManager`, `scheduler`]"
}

variable "cluster_log_retention_period" {
  type        = number
  default     = 0
  description = "Number of days to retain cluster logs. Requires `enabled_cluster_log_types` to be set. See https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html."
}

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
variable "hostnames" { type = list(string) }
variable "cloudflare_api_token" { sensitive = true }
variable "cloudflare_zone_id" {}
variable "datadog_api_key" {
  default   = ""
  sensitive = true
}
variable "datadog_cluster_name" { default = "" }
variable "enable_e2e" { default = true }
variable "e2e_container_image" { default = "xmtp/xmtpd-e2e:latest" }
variable "e2e_replicas" { default = 1 }

variable "eks_map_additional_iam_users" {
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default     = []
  description = "Additional IAM users to add to config-map-aws-auth ConfigMap"
}
