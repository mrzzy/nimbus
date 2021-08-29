#
# nimbus
# terraform deploy for linode cloud
#

locals {
  sg_region = "ap-south"
}

terraform {
  backend "remote" {
    organization = "mrzzy-co"

    workspaces {
      name = "nimbus-terraform-linode"
    }
  }
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "1.19.1"
    }
  }
  required_version = ">=1.0.1, <1.1.0"
}

## Providers ##
provider "linode" {
  token = var.linode_token
}

## Resources ##
resource "linode_sshkey" "mrzzy_ed25519" {
  label   = "${var.prefix}-mrzzy-ed25519"
  ssh_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBrfd982D9iQVTe2VecUncbgysh/XsZb4YyOhCSSAAtr zzy"
}

# generic LKE cluster in Linode's singapore region
resource "linode_lke_cluster" "singapore" {
  label       = "${var.prefix}-singapore-k8s"
  region      = local.sg_region
  k8s_version = "1.21"

  # default node pool: 2vcpu, 24gb ram
  pool {
    type  = "g7-highmem-1"
    count = 1
  }

  tags = setunion(var.tags, ["sgp"])
}

# firewall to safeguard against giving unintentional public access to LKE k8s nodeport services
resource "linode_firewall" "lke_singapore" {
  label = "${var.prefix}-sgp-lke-nodes"
  tags  = setunion(var.tags, ["sgp"])
  linodes = flatten(
    [for pool in linode_lke_cluster.singapore.pool :
      [for node in pool.nodes : node.instance_id]
    ]
  )

  inbound_policy = "DROP"
  inbound {
    label    = "allow-shadowsocks"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "32121"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  outbound_policy = "ACCEPT"
}

# bastion host providing wireguard vpn access to SG LKE cluster allows us to
# provide services to the LKE cluster without exposing them to the public internet
module "bastion_singapore" {
  source = "./modules/wireguard"
  prefix = "bastion"

  linode_region = local.sg_region
  ssh_keys      = [linode_sshkey.mrzzy_ed25519.ssh_key]

  wireguard_server_private_key = var.bastion_wireguard_private_key
  wireguard_peers = {
    "0wBcwb/2jI+Xj8TBMkKYdRUHgjNKpb0dkdCrFv9AlAs=" = "172.31.255.2" # pragma: allowlist secret
    "qWVEEa0sMEWnVqTNqWaGz9WFEB+4ur+Idu3Uip58DxE=" = "172.31.255.3" # pragma: allowlist secret
  }

  tags = setunion(var.tags, ["sgp"])
}
