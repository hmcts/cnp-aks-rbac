resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.name}-${var.env}"
  location            = "${var.location}"
  resource_group_name = "${var.env}"
  dns_prefix          = "${var.name}"
  kubernetes_version  = "${var.kubernetes_version}"

  agent_pool_profile {
    name            = "aks${replace(var.env, "-", "")}"
    count           = "${var.aks_initial_cluster_size}"
    vm_size         = "${var.aks_vm_size}"
    os_type         = "Linux"
    os_disk_size_gb = 100

    vnet_subnet_id = "${azurerm_subnet.aks_sb.id}"
  }

  service_principal {
    client_id     = "${var.aks_sp_client_id}"
    client_secret = "${var.aks_sp_client_secret}"
  }

  role_based_access_control {
    enabled = true

    azure_active_directory {
      client_app_id     = "${var.aks_ad_client_app_id}"
      server_app_id     = "${var.aks_ad_server_app_id}"
      server_app_secret = "${var.aks_ad_server_app_secret}"
    }
  }

  linux_profile {
    admin_username = "adminssh"

    ssh_key {
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDMeey/GpPjgzx7T4i04yWcsXWG9AG/oqDTYZMqC5Sxc9s2TEXWII8Xf4vbvhduEGhlZb/GMOA/VxRscm+yThiisIWPTMWz1LH6s59uOLxJvqA67Bx/xqibPlY56chI/7Vb0Z5YlLyNUz+jk4RGmYFn9x9YuirY9YWmvUZXFgFI8zVPk+QUYWRcV3ez5nlvabY5x+/cXmwcHh+/JP67dvWk6IsHktVaE4U8pS6CHZSqlQlfLZueelg2qnA5jfLD9KAfO1xDNbWjrgEYQ3IpiMJBex2gdBqLUF9kjFK9upWbc0ooBVSKmqqvMYKmcKJq99Ux1uh47Kt3kePT3OKom2CPI3iPryX2MiljDuJlxxcsFSmD+90yt21Bk/c4LW5R1G7DCGxaX3nHQqacho6QO6QcKG+G/NgpuEDc8AcP9u+AAwtOop+2M16vEUg2RiyGFcibch0DR+/N9WkUHEZHQ8m50fgBpiUoxjRhiD0Qeq2Lkeb6RfbcwtIAR9aD42a+PywMCT6VIBM/MDmp2rUG4sc3mDV55uUFAbBTSi1/PT278W0wtZh2oj/q1jqCN3O/dV2sgFblp28/OSgDQ/xdDUFvhniAn/NBOc3UwugIMPxeEWhWzSbEIbogG1lQsySI7mGQa2zEzklq7/3kxIHsWoYnH0M360XmM32d9s5e3tWr6w=="
    }
  }

  network_profile {
    network_plugin = "azure"
  }

  tags = "${var.common_tags}"
}
