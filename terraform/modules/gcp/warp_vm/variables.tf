#
# Nimbus
# Terraform Deployment: WARP VM on GCP
# Input Variables
#

variable "enabled" {
  type        = bool
  description = "Whether to deploy the WARP development VM instance."
  default     = true
}

variable "image" {
  type        = string
  description = "Name of the VM image used to boot WARP development VM"
  default     = "warp-box"
}

variable "machine_type" {
  type        = string
  description = "GCE machine type to use for WARP development VM"
  default     = "e2-standard-2"
}

variable "disk_size_gb" {
  type        = number
  description = "Size of the disk used mounted on the WARP development VM for persistent storage"
  default     = 10
}

variable "tags" {
  type        = list(string)
  description = "List of GCE Metadata tags to add to the VM instance."
}

variable "web_tls_cert" {
  type        = string
  description = <<-EOF
  Full chain TLS certificate used to verify WARP VM identity when connecting
  via its Web Terminal. The certificate should be encoded in the PEM format.
  EOF
}

variable "web_tls_key" {
  type        = string
  sensitive   = true
  description = <<-EOF
  Private key of the TLS certificate used by the WARP VM's Web Terminal.
  The private key should be encoded in the PEM format.
  EOF
}

variable "ssh_public_key" {
  type        = string
  description = "Public SSH Key to authorize on WARP VM for access via SSH."
}
