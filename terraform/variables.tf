#
# Nimbus
# Terraform Deployment
# Input Variables
#

variable "acme_server_url" {
  type        = string
  description = "URL of the ACME server to use to obtain TLS certificates from."
  # use LetsEncrypt's production server to issue trusted TLS certificates
  default = "https://acme-v02.api.letsencrypt.org/directory"
}
