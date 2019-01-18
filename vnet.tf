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

resource "azurerm_route_table" "aks_subnet_route" {
  name                = "${var.name}-${var.env}-aks"
  location            = "${azurerm_resource_group.core_infra_rg.location}"
  resource_group_name = "${azurerm_resource_group.core_infra_rg.name}"

  route {
    name                   = "default"
    address_prefix         = "10.100.0.0/14"    # not sure what should go here
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.10.1.1"        # or here
  }

  tags = "${var.common_tags}"
}

resource "azurerm_network_security_group" "default_nsg" {
  name                = "default-${var.env}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.core_infra_rg.name}"

  tags = "${var.common_tags}"
}

resource "azurerm_subnet" "aks_sb" {
  name                      = "aks-${local.deployment_env}"
  resource_group_name       = "${azurerm_resource_group.core_infra_rg.name}"
  virtual_network_name      = "${azurerm_virtual_network.vnet.name}"
  address_prefix            = "${cidrsubnet(element(azurerm_virtual_network.vnet.address_space,0), 2, 3)}"
  service_endpoints         = ["Microsoft.KeyVault", "Microsoft.Storage"]
  #network_security_group_id = "${azurerm_network_security_group.default_nsg.id}"

  # this field is deprecated and will be removed in 2.0 - but is required until then
  #route_table_id = "${azurerm_route_table.aks_subnet_route.id}"

  lifecycle {
    ignore_changes = "address_prefix"
  }
}

resource "azurerm_subnet_route_table_association" "aks_subnet_association" {
  subnet_id      = "${azurerm_subnet.aks_sb.id}"
  route_table_id = "${azurerm_route_table.aks_subnet_route.id}"
}

# Subnet <Network Security Group associations currently need to be configured on both this resource 
# and using the network_security_group_id field on the azurerm_subnet resource. The next major version 
# of the AzureRM Provider (2.0) will remove the network_security_group_id field from the azurerm_subnet
# resource above such that this resource is used to link resources in future.
resource "azurerm_subnet_network_security_group_association" "aks_nsg_link" {
  subnet_id                 = "${azurerm_subnet.aks_sb.id}"
  network_security_group_id = "${azurerm_network_security_group.default_nsg.id}"
}
