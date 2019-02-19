resource "azurerm_subnet" "app_gateway" {
  name                      = "app-gateways"
  resource_group_name       = "${azurerm_resource_group.core_infra_rg.name}"
  virtual_network_name      = "${azurerm_virtual_network.vnet.name}"
  address_prefix            = "${var.ag_subnet_address_space}"
  network_security_group_id = "${azurerm_network_security_group.allow_internet_nsg.id}"

  lifecycle {
    ignore_changes = "address_prefix"
  }
}

# Subnet <Network Security Group associations currently need to be configured on both this resource
# and using the network_security_group_id field on the azurerm_subnet resource. The next major version
# of the AzureRM Provider (2.0) will remove the network_security_group_id field from the azurerm_subnet
# resource above such that this resource is used to link resources in future.
resource "azurerm_subnet_network_security_group_association" "ag_nsg_link" {
  subnet_id                 = "${azurerm_subnet.app_gateway.id}"
  network_security_group_id = "${azurerm_network_security_group.allow_internet_nsg.id}"
}
