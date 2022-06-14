#
# Nimbus
# Terraform Deployment: Google Cloud Platform
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
