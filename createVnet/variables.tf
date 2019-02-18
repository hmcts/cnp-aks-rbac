variable "address_space" {
  default = "10.160.128.0/18"
}
variable "ag_subnet_address_space" {
  default = "10.160.128.0/24"
}


variable "location" {
  default = "UK South"
}

variable "env" {}

variable "common_tags" {
  type = "map"
}
