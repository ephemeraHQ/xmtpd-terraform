variable "namespace" {}
variable "node_pool_label_key" {}
variable "node_pool" {}
variable "ingress_class_name" {}
variable "wait_for_ready" {}
variable "enable_chat_app" { type = bool }
variable "enable_monitoring" { type = bool }
variable "datadog_api_key" { default = "" }
variable "datadog_cluster_name" { default = "" }
variable "node_hostnames_internal" { type = list(string) }
variable "chat_app_hostnames" { type = list(string) }
variable "grafana_hostnames" { type = list(string) }
variable "prometheus_hostnames" { type = list(string) }
variable "node_container_port" { type = number }
variable "public_api_url" {}
variable "chat_app_container_image" {}
variable "enable_e2e" { type = bool }
variable "e2e_container_image" {}
variable "e2e_replicas" { type = number }
variable "e2e_delay" { default = "" }
variable "e2e_admin_port" { type = number }
