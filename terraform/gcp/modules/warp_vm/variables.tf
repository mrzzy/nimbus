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

variable "allow_ssh_tag" {
  type        = string
  description = "GCE Metadata tag to attach to enable ssh access to WARP development VM"
}
