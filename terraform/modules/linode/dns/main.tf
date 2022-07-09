#
# Nimbus
# Terraform Deployment: Linode Managed DNS
#

terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = ">=1.28.0, <1.29.0"
    }
  }
}

resource "linode_domain" "domain" {
  domain      = var.domain
  description = "DNS zone for the ${var.domain} domain"
  soa_email   = "admin@${var.domain}"

  # create an authorizative DNS zone (master)
  type = "master"

  depends_on = [
    linode_instance.dummy
  ]
}

resource "linode_domain_record" "route" {
  for_each  = var.routes
  domain_id = linode_domain.domain.id

  record_type = "A"
  ttl_sec     = 300 # 5 minutes

  name   = each.key
  target = each.value
}

# TODO(mrzzy): remove instance.
# Linode Managed DNS requires at least 1 instance to be running in order for
# DNS records to be served. Create a dummy instance to satisfy this requirement.
resource "linode_instance" "dummy" {
  label  = "dns-dummy"
  region = "ap-south"
  type   = "g6-nanode-1"
}
