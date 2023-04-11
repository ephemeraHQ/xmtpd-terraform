variable "namespace" {}
variable "node_pool_label_key" {}
variable "node_pool" {}
variable "ingress_class_name" {}
variable "wait_for_ready" {}
variable "enable_chat_app" { type = bool }
variable "enable_monitoring" { type = bool }
variable "chat_app_hostnames" { type = list(string) }
variable "grafana_hostnames" { type = list(string) }
variable "jaeger_hostnames" { type = list(string) }
variable "prometheus_hostnames" { type = list(string) }
variable "public_api_url" {}
variable "chat_app_container_image" {}
