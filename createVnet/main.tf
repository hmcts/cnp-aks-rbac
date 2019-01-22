terraform {
  backend "azurerm" {}
}

resource "azurerm_resource_group" "core_infra_rg" {
  name     = "${var.name}-${var.env}"
  location = "${var.location}"

  tags {
    environment = "${var.env}"
  }
}
