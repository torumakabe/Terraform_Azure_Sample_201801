provider "azurerm" {}

data "azurerm_resource_group" "resource_group" {
  name = "${var.resource_group_name}-${terraform.workspace}-rg"
}

module "network" {
  source              = "../../modules/network"
  resource_group_name = "${data.azurerm_resource_group.resource_group.name}"
  location            = "${data.azurerm_resource_group.resource_group.location}"
  allow_http_traffic  = true
  allow_ssh_traffic   = true

  tags = {
    environment = "${terraform.workspace}"
    cost-center = "${var.cost-center}"
  }
}

resource "azurerm_public_ip" "jumpbox" {
  name                         = "jumpbox-public-ip"
  resource_group_name          = "${data.azurerm_resource_group.resource_group.name}"
  location                     = "${data.azurerm_resource_group.resource_group.location}"
  public_ip_address_allocation = "static"
  domain_name_label            = "${data.azurerm_resource_group.resource_group.name}-ssh"
  depends_on                   = ["module.network"]

  tags = {
    environment = "${terraform.workspace}"
    cost-center = "${var.cost-center}"
  }
}

resource "azurerm_network_interface" "jumpbox" {
  name                = "jumpbox-nic"
  resource_group_name = "${data.azurerm_resource_group.resource_group.name}"
  location            = "${data.azurerm_resource_group.resource_group.location}"

  ip_configuration {
    name                          = "IPConfiguration"
    subnet_id                     = "${module.network.vnet_subnets[0]}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.jumpbox.id}"
  }

  tags = {
    environment = "${terraform.workspace}"
    cost-center = "${var.cost-center}"
  }
}

resource "azurerm_virtual_machine" "jumpbox" {
  name                  = "jumpbox"
  resource_group_name   = "${data.azurerm_resource_group.resource_group.name}"
  location              = "${data.azurerm_resource_group.resource_group.location}"
  network_interface_ids = ["${azurerm_network_interface.jumpbox.id}"]
  vm_size               = "Standard_B1s"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "jumpbox-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  delete_os_disk_on_termination = true

  os_profile {
    computer_name  = "jumpbox"
    admin_username = "${var.admin_username}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = "${file("~/.ssh/id_rsa.pub")}"
    }
  }

  tags = {
    environment = "${terraform.workspace}"
    cost-center = "${var.cost-center}"
  }
}
