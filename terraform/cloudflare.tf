#
# Nimbus
# Terraform Deployment
# Cloudflare
#

locals {
  cf_account_id = "3a282e33c95eef3f663f0fc3e028b6df"
  # static ips to expose via dns
  warp_ip         = module.warp_vm.external_ip
  art_bucket_host = "f004.backblazeb2.com"
  art_subdomain   = "art"
  art_domain      = "${local.art_subdomain}.${local.domain}"
}

# Cloudflare: expects access token provided via $CLOUDFLARE_API_TOKEN env var
provider "cloudflare" {}

data "cloudflare_zone" "mrzzy_co" {
  account_id = local.cf_account_id
  name       = local.domain
}

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
    # dns routes for mrzzy.co site
    art_site = {
      type      = "CNAME",
      subdomain = local.art_subdomain
      # serve static files from b2 bucket
      value   = local.art_bucket_host
      proxied = true
      ttl     = 1
    },
    },
    # only create dns route for WARP VM if its deployed
    var.has_warp_vm ? { warp = { subdomain = "warp", value = local.warp_ip } } : {}
  ))
}

resource "cloudflare_zone_settings_override" "mrzzy_co" {
  zone_id = data.cloudflare_zone.mrzzy_co.id
  settings {
    # enforce https
    ssl                      = "strict"
    always_use_https         = "on"
    automatic_https_rewrites = "on"
  }
}

resource "cloudflare_ruleset" "art_mrzzy_co_http_transform" {
  zone_id = data.cloudflare_zone.mrzzy_co.id
  name    = "${local.art_domain} Transform"
  kind    = "zone"
  phase   = "http_request_transform"

  // html files
  rules {
    description = "Add bucket prefix & '.html' suffix to path to serve ${local.art_domain} HTML from B2 bucket."
    enabled     = true
    action      = "rewrite"
    expression  = "((http.host eq \"${local.art_domain}\") and (http.request.uri.path.extension eq \"\"))"
    action_parameters {
      uri {
        path {
          expression = "concat(\"/file/${b2_bucket.art_mrzzy_co.bucket_name}\", http.request.uri.path, \".html\")"
        }
      }
    }
  }

  // non-html assets
  rules {
    description = "Add bucket name prefix to path to serve ${local.art_domain} from B2 bucket."
    enabled     = true
    action      = "rewrite"
    expression  = "((http.host eq \"${local.art_domain}\") and (http.request.uri.path.extension ne \"\"))"
    action_parameters {
      uri {
        path {
          expression = "concat(\"/file/${b2_bucket.art_mrzzy_co.bucket_name}\", http.request.uri.path)"
        }
      }
    }
  }

  // serve index.html at root
  rules {
    description = "Rewrite '/' to 'index.html'"
    enabled     = true
    action      = "rewrite"
    expression  = "((http.host eq \"${local.art_domain}\") and (http.request.uri.path eq \"/\"))"
    action_parameters {
      uri {
        path {
          value = "/file/${b2_bucket.art_mrzzy_co.bucket_name}/index.html"
        }
      }
    }
  }
}
