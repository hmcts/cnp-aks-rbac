resource "azurerm_virtual_network" "vnet" {
  name                = "${var.env}"
  resource_group_name = "${azurerm_resource_group.core_infra_rg.name}"
  address_space       = ["${var.address_space}"]
  location            = "${azurerm_resource_group.core_infra_rg.location}"

  lifecycle {
    ignore_changes = ["address_space", "dns_servers"]
  }

  tags = "${var.common_tags}"
}
