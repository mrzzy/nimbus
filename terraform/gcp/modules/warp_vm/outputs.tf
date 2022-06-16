#
# Nimbus
# Terraform Deployment: WARP VM on GCP
# Output variables
#

output "external_ip" {
  description = "Publicly accessible IP of the WARP VM."
  value       = google_compute_instance.wrap_vm[0].network_interface[0].access_config[0].nat_ip
}
