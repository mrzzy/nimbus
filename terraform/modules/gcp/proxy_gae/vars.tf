#
# Nimbus
# Terraform Module
# GAEProxy on GCP: Input Vars
#

variable "container" {
  type        = string
  description = "GAEProxy container image to deploy on App Engine."
}

variable "proxy_spec" {
  type        = string
  description = <<-EOF
    Specify routes that should be proxied in the format:
    '/<ROUTE>=<TARGET> [/<ROUTE>=<TARGET2> ...]'
    Example: '/proxy=https://proxy.me' will proxy all requests sent to
    '/proxy/target/url' to 'https://proxy.me/target/url'
  EOF
}

variable "project_id" {
  type        = string
  description = "ID of the GCP project that GAEProxy will deploy to."
}

variable "region" {
  type        = string
  description = "GCP Region that GAEProxy will deploy to."
}
