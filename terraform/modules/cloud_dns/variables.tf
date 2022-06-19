#
# Nimbus
# Terraform Deployment: Google Cloud DNS
# Input Variables
#

variable "domain" {
  type        = string
  description = "Domain managed by Cloud DNS"
}

variable "routes" {
  type        = map(string)
  description = "Map of subdomain host to IP of DNS A routes to create."
}
