#
# nimbus
# Linode Terraform
# Wireguard VPN Module
#

output "wireguard_ip" {
  value = linode_instance.wireguard.ip_address
  description = "IP address the Wireguard server is listen on"
}
