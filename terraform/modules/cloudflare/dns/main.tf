#
# Nimbus
# Terraform Deployment
# Cloudflare DNS
#

terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "3.30.0"
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

  type  = "A"
  ttl   = 60 # 1 min
  name  = each.key
  value = each.value
}
