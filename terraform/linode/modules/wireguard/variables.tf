#
# nimbus
# Linode Terraform
# Wireguard VPN Module
#

variable "vpn_cidr_length" {
  type = number
  description = "CIDR prefix length of the VPN network"
  default = 24
}

variable "wireguard_server_vpn_ip" {
  type = string
  description = "IP address to assign the Wireguard server in the VPN network"
  default = "172.31.255.1"
}
variable "wireguard_port" {
  type = number
  description = "Port on which the Wireguard server listens on"
  default = 51820
}

variable "wireguard_server_private_key" {
  type = string
  sensitive = true
  description = "Private key to be used by the Wireguard server"
}

variable "wireguard_peers" {
  type = map(string)
  description = "Map of Peer Public Key to IPv4 address of Wireguard Peers"
}

variable "linode_region" {
  type        = string
  description = "Linode region to deploy the linode instance hosting the wireguard server to"
}


variable "prefix" {
  type        = string
  description = "Prefix to attach to labels of created resources"
  default = ""
}

variable "tags" {
  type        = set(string)
  description = "List of unique tags to apply to deployed resources"

  default = [
    "terraform"
  ]
}
