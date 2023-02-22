####################################################################################################
# Creating base resource
resource "azurerm_resource_group" "AksRg" {

  name     = "${var.Aks.RgName}${var.Aks.Suffix}"
  location = var.Aks.Location
}

####################################################################################################
# Creating a user identity and assigning roles to it
resource "azurerm_user_assigned_identity" "AksUserIdentity" {

  name                = "${var.Aks.AksName}identity"
  location            = azurerm_resource_group.AksRg.location
  resource_group_name = azurerm_resource_group.AksRg.name
}

resource "azurerm_role_assignment" "AksRgContributorRole" {

  principal_id                     = azurerm_user_assigned_identity.AksUserIdentity.principal_id
  role_definition_name             = "Contributor"
  scope                            = azurerm_resource_group.AksRg.id
  skip_service_principal_aad_check = true
}

data "azurerm_resource_group" "AksNodeRg" {

  name = azurerm_kubernetes_cluster.Aks.node_resource_group
}

resource "azurerm_role_assignment" "VirtualMachineContributorRole" {

  principal_id                     = azurerm_user_assigned_identity.AksUserIdentity.principal_id
  role_definition_name             = "Virtual Machine Contributor"
  scope                            = data.azurerm_resource_group.AksNodeRg.id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "AcrPullRole" {

  principal_id                     = azurerm_user_assigned_identity.AksUserIdentity.principal_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.Acr.id
  skip_service_principal_aad_check = true
}

####################################################################################################
# Container registry resource
resource "azurerm_container_registry" "Acr" {

  name                = "${var.Aks.AcrName}${var.Aks.Suffix}"
  location            = azurerm_resource_group.AksRg.location
  resource_group_name = azurerm_resource_group.AksRg.name
  sku                 = "Standard"
  admin_enabled       = false
}

####################################################################################################
# Log analytics resources configuration
resource "azurerm_log_analytics_workspace" "Law" {

  name                = "${var.Aks.LawName}${var.Aks.Suffix}"
  location            = azurerm_resource_group.AksRg.location
  resource_group_name = azurerm_resource_group.AksRg.name
}

resource "azurerm_log_analytics_solution" "LawContainerSolution" {

  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.AksRg.location
  resource_group_name   = azurerm_resource_group.AksRg.name
  workspace_resource_id = azurerm_log_analytics_workspace.Law.id
  workspace_name        = azurerm_log_analytics_workspace.Law.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

####################################################################################################
# Network resources configuration
resource "azurerm_virtual_network" "Vnet" {

  name                = "${var.Aks.VnetName}${var.Aks.Suffix}"
  location            = azurerm_resource_group.AksRg.location
  resource_group_name = azurerm_resource_group.AksRg.name
  address_space       = var.Aks.VnetAddressSpace
}

resource "azurerm_subnet" "AksSubnet" {

  name                 = var.Aks.AksSubnetName
  resource_group_name  = azurerm_resource_group.AksRg.name
  virtual_network_name = azurerm_virtual_network.Vnet.name
  address_prefixes     = var.Aks.AksSubnetCIDR
}

####################################################################################################
# Aks resource configuration
resource "azurerm_kubernetes_cluster" "Aks" {

  name                = lower("${var.Aks.AksName}${var.Aks.Suffix}")
  location            = azurerm_resource_group.AksRg.location
  resource_group_name = azurerm_resource_group.AksRg.name

  dns_prefix                = lower("${var.Aks.AksName}${var.Aks.Suffix}")
  kubernetes_version        = var.Aks.KubeVersion
  automatic_channel_upgrade = "patch"
  sku_tier                  = "Free"
  node_resource_group       = lower("mc-${var.Aks.RgName}-${var.Aks.Location}-${var.Aks.AksName}-${var.Aks.Suffix}")

  default_node_pool {
    name       = "systemnode"
    node_count = 1
    # enable_auto_scaling = true
    # min_count           = 1
    # max_count           = 2
    max_pods        = 100
    vm_size         = var.Aks.DefaultNodeVMSku
    os_disk_size_gb = 50
    os_sku          = "Ubuntu"
    vnet_subnet_id  = azurerm_subnet.AksSubnet.id
    scale_down_mode = "Delete"
    type            = "VirtualMachineScaleSets"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.AksUserIdentity.id]
  }

  network_profile {
    network_plugin     = try(var.Aks.NetworkPlugin, "kubelet")
    service_cidr       = try(var.Aks.ServiceCIDR, null)
    dns_service_ip     = try(var.Aks.DNSServiceIP, null)
    docker_bridge_cidr = try(var.Aks.DockerBridgeCIDR, null)
  }

  linux_profile {
    admin_username = var.Aks.AksAdminName

    ssh_key {
      key_data = file(var.SSHPubKeyPath)
    }
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.Law.id
  }
}

data "azurerm_kubernetes_cluster" "Aks" {
  depends_on = [azurerm_kubernetes_cluster.Aks]

  name                = azurerm_kubernetes_cluster.Aks.name
  resource_group_name = azurerm_resource_group.AksRg.name
}

####################################################################################################
# Additional Aks Node Pool resource configuration
resource "azurerm_kubernetes_cluster_node_pool" "Aks" {

  name                  = "workernode"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.Aks.id
  vm_size               = var.Aks.AksWorkerNodeVmSku

  node_count = 1
  # enable_auto_scaling = true
  # min_count           = 1
  # max_count           = 2
  max_pods        = 100
  os_disk_size_gb = 50
  os_sku          = "Ubuntu"
  os_type         = "Linux"
  vnet_subnet_id  = azurerm_subnet.AksSubnet.id
}

####################################################################################################
# Updating a default Aks Load Balancer with a domain name
data "azurerm_public_ip" "AksLBIP" {
  depends_on = [data.azurerm_kubernetes_cluster.Aks]

  name                = reverse(split("/", tolist(azurerm_kubernetes_cluster.Aks.network_profile.0.load_balancer_profile.0.effective_outbound_ips)[0]))[0]
  resource_group_name = azurerm_kubernetes_cluster.Aks.node_resource_group
}

resource "azapi_update_resource" "AksLBIPDomainUpdate" {
  depends_on = [data.azurerm_public_ip.AksLBIP]

  type        = "Microsoft.Network/publicIPAddresses@2020-08-01"
  resource_id = data.azurerm_public_ip.AksLBIP.id

  body = jsonencode({
    properties = {
      dnsSettings = {
        domainNameLabel = lower("${var.Aks.AksLBIPDomainName}${var.Aks.Suffix}")
      }
    }
  })
}

data "azurerm_public_ip" "AksLBFQDN" {
  depends_on = [azapi_update_resource.AksLBIPDomainUpdate]

  name                = reverse(split("/", tolist(azurerm_kubernetes_cluster.Aks.network_profile.0.load_balancer_profile.0.effective_outbound_ips)[0]))[0]
  resource_group_name = azurerm_kubernetes_cluster.Aks.node_resource_group
}

####################################################################################################
# Generating local kubeconfig file
resource "random_integer" "Kubeconfig" {
  count = try(var.Aks.GenKubeConfig, false) == true ? 1 : 0

  min = 10000
  max = 99999
}

resource "local_file" "KubeConfig" {
  depends_on = [azurerm_kubernetes_cluster.Aks, azurerm_kubernetes_cluster_node_pool.Aks]
  count      = try(var.Aks.GenKubeConfig, false) == true ? 1 : 0

  filename = lower("kubeconfig-${var.Aks.AksName}${var.Aks.Suffix}-${random_integer.Kubeconfig[count.index].result}")
  content  = azurerm_kubernetes_cluster.Aks.kube_config_raw
}
