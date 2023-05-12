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
  type = map(object({
    type      = optional(string, "A"),
    subdomain = string,
    value     = string,
    proxied   = optional(bool, false),
  }))
  description = "List of DNS routes to create with subdomain prefix as key & given value."
}
