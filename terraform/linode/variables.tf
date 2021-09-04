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

variable "tags" {
  type        = set(string)
  description = "List of unique tags to apply to deployed resources"

  default = [
    "terraform"
  ]
}

variable "bastion_wireguard_private_key" {
  type        = string
  sensitive   = true
  description = "Private Key used by the Wireguard VPN exposed by the bastion host"
}
