#
# Nimbus
# Terraform Deployment: Google Cloud DNS
#

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=4.22.0, <4.23.0"
    }
  }
}

resource "google_dns_managed_zone" "zone" {
  name        = replace(var.domain, ".", "-")
  dns_name    = "${var.domain}."
  description = "DNS zone for the ${var.domain} domain"
}

resource "google_dns_record_set" "route" {
  for_each     = var.routes
  managed_zone = google_dns_managed_zone.zone.name
  type         = "A"
  ttl          = 300

  name    = "${each.key}.${google_dns_managed_zone.zone.dns_name}"
  rrdatas = [each.value]
}