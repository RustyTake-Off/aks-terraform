####################################################################################################
# Terraform configuration
terraform {

  ##################################################
  # Required Terraform version
  required_version = ">= 1.3.0, < 2.0.0"

  ##################################################
  # Required providers
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~>1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }

  ##################################################
  # Backend for storing state files
  /*backend "azurerm" {
    resource_group_name  = ""
    storage_account_name = ""
    container_name       = ""
    key                  = ""
  }*/
}

####################################################################################################
# Provider configuration
provider "azurerm" {
  features {}
}
