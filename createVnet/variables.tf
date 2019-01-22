variable "address_space" {}

variable "location" {
  default = "UK South"
}

variable "env" {}

variable "name" {
  default = "core-infra"
}

variable "common_tags" {
  type = "map"
}
