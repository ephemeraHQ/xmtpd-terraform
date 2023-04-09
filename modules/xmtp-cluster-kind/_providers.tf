provider "kubernetes" {
  config_path = module.k8s.kubeconfig_path
}

provider "helm" {
  kubernetes {
    config_path = module.k8s.kubeconfig_path
  }
}
