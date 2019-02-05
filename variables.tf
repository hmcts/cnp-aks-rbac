variable "location" {
  default = "UK South"
}

variable "env" {}

variable "name" {
  default = "core-infra"
}

variable "aks_vm_size" {
  default = "Standard_B4ms"
}

variable "aks_sp_client_id" {}

variable "aks_sp_client_secret" {}

variable "aks_initial_cluster_size" {
  default = 1
}

variable "aks_ad_client_app_id" {}
variable "aks_ad_server_app_id" {}
variable "aks_ad_server_app_secret" {}

variable "kubernetes_version" {
  default = "1.11.5"
}

variable "common_tags" {
  type = "map"
}
