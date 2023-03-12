#
# Nimbus
# Terraform Deployment: Identity & Access
# Output Variables
#

output "gh_actions_service_account_ids" {
  description = "IDs of Service Accounts created to identfy Github Actions workers."
  value       = { for key, account in google_service_account.actions : key => account.id }
}

output "gke_service_account_email" {
  description = "Email of the service account used to authenticate GKE workloads."
  value       = google_service_account.gke.email
}
