#
# Nimbus
# Terraform Module
# GAEProxy on GCP
# Outputs
#

output "hostname" {
  description = "Hostname used to access GAEProxy based on how App Engine Routes requests."
  value       = local.proxy_host
}
