#
# Nimbus
# Terraform Deployment
# Cloudflare DNS
#

terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.41.0"
    }
  }
}

resource "cloudflare_zone" "domain" {
  account_id = var.account_id
  zone       = var.domain
  plan       = "free" # pricing plan
}

resource "cloudflare_record" "route" {
  for_each = var.routes
  zone_id  = cloudflare_zone.domain.id

  type     = each.value.type
  ttl      = each.value.ttl
  name     = each.value.subdomain
  value    = each.value.value
  proxied  = each.value.proxied
  priority = each.value.priority
}
