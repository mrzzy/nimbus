#
# Nimbus
# Terraform Deployment: Identity & Access
# Output Variables
#

output "warp_vm_service_account" {
  value       = google_service_account.warp.email
  description = "Email of the service account for WARP VM."
}
