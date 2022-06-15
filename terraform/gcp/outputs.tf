#
# Nimbus
# Terraform Deployment: Google Cloud Platform
# Output
#


output "warp_vm_ip" {
  description = "Publicly accessible IP of the WARP VM."
  value       = module.warp_vm.external_ip
}
