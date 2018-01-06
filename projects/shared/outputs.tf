output "vnet_subnet" {
  value = "${module.network.vnet_subnets[0]}"
}
