#
# Nimbus
# Terraform Deployment: TLS Certificates
# Inputs Variables
#

variable "common_name" {
  type        = string
  description = "Common Name field of the TLS certificate issued. See RFC 2818, 6125."
}

variable "domains" {
  type        = list(string)
  description = "List of domains to validate & authenticate in TLS certificate issued."
}

variable "gcp_project_id" {
  type        = string
  description = <<-EOF
  Google Cloud Project ID with the Cloud DNS service enabled.

  Uses Cloud DNS in the project to complete the ACME dns-01 challenge when issuing
  TLS certificates
  EOF
}
