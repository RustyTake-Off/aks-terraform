####################################################################################################
# Variables
variable "SSHPubKeyPath" {
  description = "Path to your SSH Key."
  default     = "~/.ssh/id_rsa.pub"
}
variable "Aks" {
  description = "Resources configuration"
  default = {

    Suffix   = "aztfpro02"
    Location = "westeurope"
    RgName   = "rg"
    LawName  = "law"
    AcrName  = "acr"

    VnetName         = "vnet"
    VnetAddressSpace = ["10.0.0.0/16"]
    AksSubnetOneName = "aksonesubnet"
    AksSubnetOneCIDR = ["10.0.8.0/22"]
    AksSubnetTwoName = "akstwosubnet"
    AksSubnetTwoCIDR = ["10.0.12.0/22"]

    AksName = "aks"
    # GenKubeConfig = true

    KubeVersion        = "1.24.6"
    DefaultNodeVMSku   = "Standard_B2s"
    AksWorkerNodeVmSku = "Standard_D2s_v3"
    AksAdminName       = "myaksadmin"

    NetworkPlugin    = "azure"
    ServiceCIDR      = "10.0.100.0/22"
    DNSServiceIP     = "10.0.100.10"
    DockerBridgeCIDR = "172.17.0.1/16"
    # PodCIDR          = "10.0.112.0/22"
    # NetworkPolicy    = "azure"

    AksLBIPDomainName = "aks"
  }
}
