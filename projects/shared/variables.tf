variable "resource_group_name" {
  default = "tf-sample"
}

variable "location" {
  default = {
    default.location = "japaneast"
    dev.location     = "japaneast"
    stage.location   = "japaneast"
    prod.location    = "japaneast"
  }
}

variable "cost-center" {
  default = "12345"
}

variable "admin_username" {
  default = "azureuser"
}
