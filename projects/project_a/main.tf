provider "azurerm" {}

data "azurerm_resource_group" "resource_group" {
  name = "${var.resource_group_name}-${terraform.workspace}-rg"
}

module "loadbalancer" {
  source              = "../../modules/loadbalancer"
  resource_group_name = "${data.azurerm_resource_group.resource_group.name}"
  location            = "${data.azurerm_resource_group.resource_group.location}"
  prefix              = "tf-lb"

  "lb_port" {
    http = ["80", "Tcp", "80"]
  }

  tags = {
    environment = "${terraform.workspace}"
    cost-center = "${var.cost-center}"
  }
}

module "computegroup" {
  source                                 = "Azure/computegroup/azurerm"
  resource_group_name                    = "${data.azurerm_resource_group.resource_group.name}"
  location                               = "${data.azurerm_resource_group.resource_group.location}"
  vm_size                                = "Standard_D2s_v3"
  admin_username                         = "${var.admin_username}"
  ssh_key                                = "~/.ssh/id_rsa.pub"
  nb_instance                            = 2
  vm_os_publisher                        = "Canonical"
  vm_os_offer                            = "UbuntuServer"
  vm_os_sku                              = "16.04-LTS"
  vnet_subnet_id                         = "${data.terraform_remote_state.shared.vnet_subnet}"
  load_balancer_backend_address_pool_ids = "${module.loadbalancer.azurerm_lb_backend_address_pool_id}"
  cmd_extension                          = "sudo apt-get -y install nginx"

  lb_port = {
    http = ["80", "Tcp", "80"]
  }

  tags = {
    environment = "${terraform.workspace}"
    cost-center = "${var.cost-center}"
  }
}
