####################################################################################################
# Output data
output "RgName" {
  value = azurerm_resource_group.AksRg.name
}

##################################################
# Aks output
output "AksClusterName" {
  value = azurerm_kubernetes_cluster.Aks.name
}

output "AksClusterId" {
  value = azurerm_kubernetes_cluster.Aks.id
}

output "AksKubeConfig" {
  value     = azurerm_kubernetes_cluster.Aks.kube_config_raw
  sensitive = true
}

output "AksLoadBalancerIP" {
  value = data.azurerm_public_ip.AksLBIP.ip_address
}

output "AksLoadBalancerFQDN" {
  value = data.azurerm_public_ip.AksLBFQDN.fqdn
}
