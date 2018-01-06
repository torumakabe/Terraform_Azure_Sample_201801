terraform {
  backend "azurerm" {
    resource_group_name  = "tf-sample-global-rg"
    storage_account_name = "<your storage account name>"
    container_name       = "tfstate-project-a"
    key                  = "terraform.tfstate"
  }
}

data "terraform_remote_state" "shared" {
  backend = "azurerm"

  config {
    resource_group_name  = "tf-sample-global-rg"
    storage_account_name = "<your storage account name>"
    container_name       = "tfstate-shared"
    key                  = "terraform.tfstateenv:${terraform.workspace}"
  }
}
