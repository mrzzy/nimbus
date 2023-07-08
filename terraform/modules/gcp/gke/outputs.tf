#
# Nimbus
# Google Kubernetes Engine Terraform Module
# Output Variables
#

locals {
  exports = data.kubernetes_service.exports
}

output "exported_ips" {
  value = {
    for key in keys(local.exports) : key =>
    try(one(one(one(local.exports[key].status).load_balancer).ingress).ip, null)
  }
  description = <<-EOF
  Map of External IP addresses of services exported with 'export_service_ips' or
  null if the External IP of the service is not yet available.
  EOF
}
