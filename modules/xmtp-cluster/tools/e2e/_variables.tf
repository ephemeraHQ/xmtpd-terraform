variable "name" { default = "e2e" }
variable "namespace" {}
variable "node_pool_label_key" {}
variable "node_pool_label_value" {}
variable "container_image" {}
variable "api_urls" { type = list(string) }
variable "replicas" { type = number }
