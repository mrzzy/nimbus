#
# nimbus
# Linode Terraform
# Wireguard VPN Module
#

terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = ">= 1.19.1"
    }
  }
}


# stackscript used to setup wireguard services
resource "linode_stackscript" "setup_wireguard" {
  label       = "${var.prefix}-setup-wireguard"
  description = "Bootstraps a wireguard server instance"
  images      = ["linode/ubuntu20.04", "linode/ubuntu18.04"]
  is_public   = false

  script = templatefile("${path.module}/scripts/setup_wireguard.sh.tpl", {
    cidr_length = var.vpn_cidr_length
    wg_server = {
      address_ip = var.wireguard_server_vpn_ip
      port       = var.wireguard_port
    }
    wg_peers      = var.wireguard_peers
    port_forwards = var.port_forwards
  })
}

# deploy tiny instance to run the wireguard vpn server
resource "linode_instance" "wireguard" {
  label           = "${var.prefix}-wireguard"
  image           = "linode/ubuntu20.04"
  region          = var.linode_region
  authorized_keys = var.ssh_keys

  # attach wireguard server private network so it can be used to access instances via LAN
  private_ip = true

  type = "g6-nanode-1"
  tags = setunion(var.tags)

  stackscript_id = linode_stackscript.setup_wireguard.id
  stackscript_data = {
    wg_private_key = var.wireguard_server_private_key
  }
}

# firewall to limit traffic to instance to wireguard and ssh traffic only
resource "linode_firewall" "wireguard" {
  label   = "${var.prefix}-wireguard-firewall"
  tags    = setunion(var.tags, ["sgp"])
  linodes = [linode_instance.wireguard.id]

  inbound_policy = "DROP"

  # allow wireguard VPN traffic
  inbound {
    label    = "allow-wireguard"
    action   = "ACCEPT"
    protocol = "UDP"
    ports    = var.wireguard_port
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  # allow ssh traffic for debugging purposes
  inbound {
    label    = "allow-ssh"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "22"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  outbound_policy = "ACCEPT"
}
