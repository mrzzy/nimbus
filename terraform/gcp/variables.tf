#
# Nimbus
# Terraform Deployment: Google Cloud Platform
# Input Variables
#

variable "warp_image" {
  type        = string
  description = "Name of the VM image used to boot WARP development box VM"
  default     = "warp-box"
}

variable "warp_disk_size_gb" {
  type        = number
  description = "Size of the disk used mounted on the WARP development VM for persistent storage"
  default     = 10
}
