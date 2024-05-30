#
# Nimbus
# Terraform Deployment
# Azure Cloud
#

locals {
  az_client_id       = "87d7e49e-7648-46cb-8226-0c413cfbe6cc" #gitleaks:allow
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

# Providence
# resource group for https://github.com/mrzzy/providence project resources
resource "azurerm_resource_group" "providence" {
  name     = "prefect"
  location = "Southeast Asia"
}
# service principal for authenticating Prefect on Azure
resource "azuread_application_registration" "prefect" {
  display_name = "Prefect"
}
resource "azuread_service_principal" "prefect" {
  client_id = azuread_application_registration.prefect.client_id
}
resource "azurerm_role_assignment" "prefect" {
  scope                = "/subscriptions/${local.az_subscription_id}/resourceGroups/${azurerm_resource_group.providence.name}"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.prefect.object_id
}
