#
# Nimbus
# Terraform Deployment
# Cloudflare DNS Input Variables
#

variable "account_id" {
  type        = string
  description = "Account ID identitying the Cloudflare Account manage DNS zones in."
}

variable "domain" {
  type        = string
  description = "Domain managed by Cloudflare"
}

variable "routes" {
  type        = map(string)
  description = "Map of DNS A routes to create with subdomain prefix as key & IP as value."
}

variable "cnames" {
  type        = map(string)
  description = "Map of DNS CNAME routes to create with subdomain prefix as key & target hostname as value."
  default     = {}
}
