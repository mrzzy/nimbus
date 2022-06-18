#
# Nimbus
# Terraform Deployment: Google Cloud Platform
# Output
#

output "warp_vm_ip" {
  description = "Publicly accessible IP of the WARP VM."
  value       = local.warp_ip
}
