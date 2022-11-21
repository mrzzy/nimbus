#
# Nimbus
# Terraform Module
# GAEProxy on GCP: Input Vars
#

variable "container" {
  type        = string
  description = "GAEProxy container image to deploy on App Engine."
}

variable "proxy_url" {
  type        = string
  description = "Target URL the proxy should proxy traffic to."
}
