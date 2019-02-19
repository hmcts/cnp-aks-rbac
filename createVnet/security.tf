
resource "azurerm_network_security_group" "default_nsg" {
  name                = "default-${var.env}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.core_infra_rg.name}"

  tags = "${var.common_tags}"
}


resource "azurerm_network_security_group" "allow_internet_nsg" {
  name                = "internet-${var.env}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.core_infra_rg.name}"

  tags = "${var.common_tags}"

  security_rule {
    name                       = "Internet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_rule" "internet_allow_rule" {
  name                        = "Internet"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.core_infra_rg.name}"
  network_security_group_name = "${azurerm_network_security_group.allow_internet_nsg.name}"
}