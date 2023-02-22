####################################################################################################
# Output data
output "RgName" {
  value = azurerm_resource_group.AksRg.name
}

##################################################
# Aks output
output "AksClusterName" {
  value = data.azurerm_kubernetes_cluster.Aks.name
}
output "AksClusterId" {
  value = data.azurerm_kubernetes_cluster.Aks.id
}
output "AksLoadBalancerIP" {
  value = data.azurerm_public_ip.AksLBIP.ip_address
}
output "AksLoadBalancerFQDN" {
  value = data.azurerm_public_ip.AksLBFQDN.fqdn
}
