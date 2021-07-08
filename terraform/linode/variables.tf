#
# nimbus
# terraform deploy for linode cloud
# input variables
#

variable "linode_token" {
  type        = string
  sensitive   = true
  description = "Linode Personal Access Token for authenticating with Linode"
}

variable "prefix" {
  type        = string
  description = "Prefix to attach to labels of created resources"
}
