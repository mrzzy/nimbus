#
# Nimbus
# Terraform Deployment
# Cloudflare
#

locals {
  cf_account_id = "3a282e33c95eef3f663f0fc3e028b6df"
  # static ips to expose via dns
  warp_ip = module.warp_vm.external_ip
}

# Cloudflare: expects access token provided via $CLOUDFLARE_API_TOKEN env var
provider "cloudflare" {}

# Cloudflare DNS: dns zone & routes for domain
module "dns" {
  source = "./modules/cloudflare/dns"

  account_id = local.cf_account_id
  domain     = local.domain
  routes = (merge({
    # dns routes for mrzzy.co mail routing
    mx1    = { type = "MX", subdomain = "@", value = "mx1.simplelogin.co.", priority = 10 },
    mx2    = { type = "MX", subdomain = "@", value = "mx2.simplelogin.co.", priority = 20 },
    spf    = { type = "TXT", subdomain = "@", value = "v=spf1 include:simplelogin.co ~all" },
    dkim   = { type = "CNAME", subdomain = "dkim._domainkey", value = "dkim._domainkey.simplelogin.co." },
    dkim02 = { type = "CNAME", subdomain = "dkim02._domainkey", value = "dkim02._domainkey.simplelogin.co." },
    dkim03 = { type = "CNAME", subdomain = "dkim03._domainkey", value = "dkim03._domainkey.simplelogin.co." },
    dmarc  = { type = "TXT", subdomain = "_dmarc", value = "v=DMARC1; p=quarantine; pct=100; adkim=s; aspf=s" },
    },
    # only create dns route for WARP VM if its deployed
    var.has_warp_vm ? { warp = { subdomain = "warp", value = local.warp_ip } } : {}
  ))
}

# Cloudflare settings for domain
data "cloudflare_zone" "domain" {
  account_id = local.cf_account_id
  name       = local.domain
}
