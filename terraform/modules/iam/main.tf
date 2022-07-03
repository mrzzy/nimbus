#
# Nimbus
# Terraform Deployment: Identity & Access
#

# service account for WARP VM - needed to restrict IAM permissions on WARP VM
# as the default service account gives GCP project wide editor permissions.
resource "google_service_account" "warp" {
  account_id   = "warp-vm"
  display_name = "Service account for WARP VM instance(s)."
}
