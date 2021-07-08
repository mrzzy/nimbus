#
# nimbus
# terraform deploy for linode cloud
#

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
  label = "mrzzy_ed25519"
  ssh_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBrfd982D9iQVTe2VecUncbgysh/XsZb4YyOhCSSAAtr zzy"
}
