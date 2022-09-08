#
# Nimbus
# Terraform Deployment: TLS ACME
# Input Variables
#

variable "common_name" {
  type        = string
  description = "Common Name field of the TLS certificate issued. See RFC 2818, 6125."
}

variable "domains" {
  type        = list(string)
  description = "List of domains to validate & authenticate in the TLS certificate issued."
}

variable "dns_provider" {
  type        = string
  description = "Name of DNS Provider performing the the DNS-01 ACME challenge."
}
