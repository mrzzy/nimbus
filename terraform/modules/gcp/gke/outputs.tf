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
    one(one(one(local.exports[key].status).load_balancer).ingress).ip
  }
  description = "External IP address of services exported with 'export_service_ips'."
}
