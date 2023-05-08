variable "namespace" {}
variable "node_pool_label_key" {}
variable "node_pool" {}
variable "cluster_http_node_port" {
  type    = number
  default = null
}
variable "cluster_https_node_port" {
  type    = number
  default = null
}
variable "ingress_class_name" {}
variable "ingress_service_type" {}
variable "ingress_service_annotations" { type = map(string) }
