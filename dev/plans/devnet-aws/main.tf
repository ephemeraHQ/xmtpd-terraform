terraform {
  backend "s3" {
    // config passed in through backend-config init args, see apply.sh
  }
}

module "cluster" {
  source = "../../../modules/xmtp-cluster-aws"

  name_prefix                  = "xmtp-devnet"
  region                       = var.region
  availability_zones           = var.availability_zones
  vpc_cidr_block               = "172.16.0.0/16"
  kubernetes_version           = var.kubernetes_version
  enabled_cluster_log_types    = ["audit"]
  cluster_log_retention_period = 7
  hostnames                    = var.hostnames
  enable_chat_app              = var.enable_chat_app
  enable_monitoring            = var.enable_monitoring
  chat_app_container_image     = var.chat_app_container_image

  nodes                = var.nodes
  node_keys            = var.node_keys
  node_container_image = var.node_container_image
  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_zone_id   = var.cloudflare_zone_id
  datadog_api_key      = var.datadog_api_key
  datadog_cluster_name = var.datadog_cluster_name
}
