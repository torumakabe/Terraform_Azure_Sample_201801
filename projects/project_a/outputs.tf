output "lb_public_ip_address" {
  value = "${module.loadbalancer.azurerm_public_ip_address}"
}
