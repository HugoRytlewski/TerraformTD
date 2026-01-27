output "server_public_ip" {
  value = azurerm_public_ip.pip.ip_address
}

output "website_url" {
  value = "http://${azurerm_public_ip.pip.ip_address}"
}