resource "azurerm_virtual_network" "vnet" {
  name                = "${var.name}-${var.env}"
  resource_group_name = "${azurerm_resource_group.core_infra_rg.name}"
  address_space       = ["${var.address_space}"]
  location            = "${azurerm_resource_group.core_infra_rg.location}"

  lifecycle {
    ignore_changes = ["address_space", "dns_servers"]
  }

  tags = "${var.common_tags}"
}

resource "azurerm_network_security_group" "default_nsg" {
  name                = "default-${var.env}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.core_infra_rg.name}"

  tags = "${var.common_tags}"
}
