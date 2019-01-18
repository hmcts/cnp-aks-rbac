terraform {
  backend "azurerm" {}
}

locals {
  deployment_env = "${var.env}"
}

resource "azurerm_resource_group" "core_infra_rg" {
  name     = "${var.name}-${local.deployment_env}"
  location = "${var.location}"

  tags {
    environment = "${var.env}"
  }
}
