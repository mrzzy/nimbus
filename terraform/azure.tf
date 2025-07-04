#
# Nimbus
# Terraform Deployment
# Azure Cloud
#

locals {
  az_client_id       = "1a950545-719a-40d4-b132-be93ce19b8d2" #gitleaks:allow
  az_tenant_id       = "c5f05a9f-4256-41c7-994b-2c466ff24a1d" #gitleaks:allow
  az_subscription_id = "a3c83afe-be09-4754-bdb2-a98b28a2806d" #gitleaks:allow
}
# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  client_id       = local.az_client_id
  tenant_id       = local.az_tenant_id
  subscription_id = local.az_subscription_id
}
# Configure the Microsoft AzureAD provider
provider "azuread" {
  client_id = local.az_client_id
  tenant_id = local.az_tenant_id
}
