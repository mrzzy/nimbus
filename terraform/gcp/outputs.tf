#
# Nimbus
# Terraform Deployment: Google Cloud Platform
# Output
#

locals {
  warp_ip = module.warp_vm.external_ip
}

output "warp_vm_ip" {
  description = "Publicly accessible IP of the WARP VM."
  value       = local.warp_ip == null ? null : nonsensitive(local.warp_ip)
}
