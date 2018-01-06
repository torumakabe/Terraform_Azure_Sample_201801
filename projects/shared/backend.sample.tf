terraform {
  backend "azurerm" {
    resource_group_name  = "tf-sample-global-rg"
    storage_account_name = "<your storage account name>"
    container_name       = "tfstate-shared"
    key                  = "terraform.tfstate"
  }
}
