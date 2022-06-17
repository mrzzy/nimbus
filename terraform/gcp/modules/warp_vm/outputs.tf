#
# Nimbus
# Terraform Deployment: WARP VM on GCP
# Output variables
#

output "external_ip" {
  description = "Publicly accessible IP of the WARP VM."
  value = (
    length(google_compute_instance.wrap_vm) == 0 ? null :
    one(google_compute_instance.wrap_vm).network_interface[0].access_config[0].nat_ip
  )
}
