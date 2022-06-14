#
# Nimbus
# Terraform Deployment: WARP VM on GCP
# Output variables
#

output "warp_box_ip" {
  description = "Publicly accessible IP of the WARP development VM."
  value       = google_compute_instance.wrap_vm[*].network_interface[0].access_config[0].nat_ip
}
