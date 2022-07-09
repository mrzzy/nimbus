#
# Nimbus
# Terraform Deployment: TLS ACME
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
  GCP Project ID with the Cloud DNS service enabled.

  Uses Cloud DNS in the project to complete the ACME dns-01 challenge when issuing
  TLS certificates
  EOF
}

variable "gcp_service_account_key" {
  type        = string
  sensitive   = true
  description = "GCP Service Account JSON Key for authenticate Cloud DNS requests for ACME."
}
