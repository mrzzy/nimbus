#
# Nimbus
# Terraform Deployment
# Input Variables
#

variable "has_warp_vm" {
  type        = bool
  description = "Whether to deploy the WARP development VM instance."
  default     = false
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
  default     = 30
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

variable "warp_allow_ports" {
  type        = string
  description = "Additional Comma-seperated ports to enable on WARP VM for development purposes."
  default     = ""
}

variable "has_gae_proxy" {
  type        = bool
  description = "Whether to deploy Google App Engine Proxy."
  default     = false
}

variable "gae_proxy_spec" {
  type        = string
  description = "Specify routes that should be proxied by GAE Proxy."
  default     = ""
}

variable "acme_server_url" {
  type        = string
  description = "URL of the ACME server to use to obtain TLS certificates from."
  # use LetsEncrypt's production server to issue trusted TLS certificates
  default = "https://acme-v02.api.letsencrypt.org/directory"
}
