terraform {
  backend "s3" {
    // config passed in through backend-config init args, see apply.sh
  }
}

locals {
  region = "us-east-2"
}

module "cluster" {
  source = "../../../modules/xmtp-cluster-aws"

  namespace = "xmtp"
  stage     = "devnet"
  name      = "aws"

  region                       = local.region
  availability_zones           = ["us-east-2a", "us-east-2b"]
  vpc_cidr_block               = "172.16.0.0/16"
  kubernetes_version           = "1.25"
  enabled_cluster_log_types    = ["audit"]
  cluster_log_retention_period = 7
  hostnames                    = ["snormore.dev"]
  enable_chat_app              = true
  enable_monitoring            = true

  nodes                = var.nodes
  node_keys            = var.node_keys
  node_container_image = var.node_container_image
  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_zone_id   = var.cloudflare_zone_id
}
