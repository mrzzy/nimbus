#
# Nimbus
# Terraform Deployment
# Input Variables
#

variable "has_warp_vm" {
  type        = bool
  description = "Whether to deploy the WARP development VM instance."
  default     = true
}

variable "warp_image" {
  type        = string
  description = "Name of the VM image used to boot WARP development VM"
  default     = "warp-box"
}

variable "warp_machine_type" {
  type        = string
  description = "GCE machine type to use for WARP development VM"
  default     = "e2-standard-2"
}

variable "warp_disk_size_gb" {
  type        = number
  description = "Size of the disk used mounted on the WARP development VM for persistent storage"
  default     = 10
}

variable "warp_http_terminal" {
  type        = bool
  description = "Whether to enable the publicly accessible HTTP web terminal on WARP VM."
  default     = false
}

variable "warp_allow_ip" {
  type        = string
  description = "Allow traffic to WARP VM from the given IP range in CIDR notation."
  default     = "0.0.0.0/0"
}

variable "warp_allow_dev_port" {
  type        = bool
  description = <<-EOF
    Whether to expose port 8080 to allow access to a development server for testing.
    Example: Access development web server on port 8080 when doing Web API development.
  EOF
  default     = false
}

variable "gcp_service_account_key" {
  type        = string
  sensitive   = true
  description = "GCP Service Account JSON Key used to authenticate with the GCP API."
}

variable "acme_server_url" {
  type        = string
  description = "URL of the ACME server to use to obtain TLS certificates from."
  # defaults to Lets Encrypt staging which issues self-signed test certificates.
  default = "https://acme-staging-v02.api.letsencrypt.org/directory"
}
