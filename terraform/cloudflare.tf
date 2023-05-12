#
# Nimbus
# Terraform Deployment
# Cloudflare
#

locals {
  cf_account_id = "3a282e33c95eef3f663f0fc3e028b6df"
  warp_ip       = module.warp_vm.external_ip
}

# Cloudflare: expects access token provided via $CLOUDFLARE_API_TOKEN env var
provider "cloudflare" {}

# Cloudflare DNS: dns zone & routes for domain
module "dns" {
  source = "./modules/cloudflare/dns"

  account_id = local.cf_account_id
  domain     = local.domain
  routes = (merge({                                                         # dns routes for services served by gke's ingress
    auth      = { subdomain = "auth", value = module.gke.ingress_ip },      # oauth2-proxy oauth callbacks / login page
    media     = { subdomain = "media", value = module.gke.ingress_ip },     # jellyfin media server
    monitor   = { subdomain = "monitor", value = module.gke.ingress_ip },   # Grafana monitoring
    library   = { subdomain = "library", value = module.gke.ingress_ip },   # EBook Library
    pipelines = { subdomain = "pipelines", value = module.gke.ingress_ip }, # Apache Airflow pipeline ochestrator
    analytics = { subdomain = "analytics", value = module.gke.ingress_ip }, # Apache Superset analytics
    },
    # dns routes for mrzzy.co mail routing
    # only create dns route for WARP VM if its deployed
    var.has_warp_vm ? { warp = { subdomain = "warp", value = local.warp_ip } } : {}
  ))
}

# Cloudflare settings for domain
data "cloudflare_zone" "domain" {
  account_id = local.cf_account_id
  name       = local.domain
}
