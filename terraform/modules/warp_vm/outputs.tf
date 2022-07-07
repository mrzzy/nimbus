#
# Nimbus
# Terraform Deployment: WARP VM on GCP
# Output variables
#

output "external_ip" {
  description = "Publicly accessible IP of the WARP VM."
  value = (
    length(google_compute_address.warp) == 0 ? null : one(google_compute_address.warp).address
  )
}
