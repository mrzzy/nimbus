#
# Nimbus
# Terraform Deployment: Linode Managed DNS
# Input Variables
#

variable "domain" {
  type        = string
  description = "Domain managed by Linode Managed DNS"
}

variable "routes" {
  type        = map(string)
  description = "Map of DNS A routes to create with subdomain prefix as key & IP as value."
}
