#
# Nimbus
# Google Kubernetes Engine Terraform Module
# Output Variables
#

locals {
  ingress_statuses = data.kubernetes_service.ingress.status
}
output "ingress_ip" {
  value       = one(one(local.ingress_statuses[length(local.ingress_statuses) - 1].load_balancer).ingress).ip
  description = "External IP address used to access the Ingress Controller on K8s cluster."
}

output "ig" {
  value = data.kubernetes_service.ingress
}
