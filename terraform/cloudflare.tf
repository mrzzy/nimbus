#
# Nimbus
# Terraform Deployment
# Cloudflare
#

locals {
  cf_account_id = "3a282e33c95eef3f663f0fc3e028b6df"
  warp_ip       = module.warp_vm.external_ip
  ingress_ip    = module.gke.exported_ips["ingress-nginx::ingress-nginx-controller"]
}

# Cloudflare: expects access token provided via $CLOUDFLARE_API_TOKEN env var
provider "cloudflare" {}

# Cloudflare DNS: dns zone & routes for domain
module "dns" {
  source = "./modules/cloudflare/dns"

  account_id = local.cf_account_id
  domain     = local.domain
  routes = (merge({
    # dns routes for services served by gke's ingress
    auth      = { subdomain = "auth", value = local.ingress_ip },      # oauth2-proxy oauth callbacks / login page
    media     = { subdomain = "media", value = local.ingress_ip },     # jellyfin media server
    monitor   = { subdomain = "monitor", value = local.ingress_ip },   # Grafana monitoring
    library   = { subdomain = "library", value = local.ingress_ip },   # EBook Library
    pipelines = { subdomain = "pipelines", value = local.ingress_ip }, # Apache Airflow pipeline ochestrator
    analytics = { subdomain = "analytics", value = local.ingress_ip }, # Apache Superset analytics
    shadowsocks = {
      subdomain = "ss", value = module.gke.exported_ips["proxy::shadowsocks"],
    },
    naiveproxy = {
      subdomain = "naive", value = module.gke.exported_ips["proxy::naiveproxy"]
    },
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
