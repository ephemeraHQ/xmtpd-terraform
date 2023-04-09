provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = module.k8s.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.k8s.eks_cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.k8s.eks_cluster_id]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.k8s.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.k8s.eks_cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.k8s.eks_cluster_id]
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
