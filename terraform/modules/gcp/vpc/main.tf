#
# Nimbus
# Terraform Deployment: VPC Network
#

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=4.22.0, <4.23.0"
    }
  }
}

# custom VPC with hardened firewall rules (as compared to default VPC)
resource "google_compute_network" "sandbox" {
  name                    = "sandbox"
  description             = "Hardend VPC Network to attach GCE resources to."
  auto_create_subnetworks = "true"
}

# create firewall rules to allow ingress traffic from the internet
resource "google_compute_firewall" "sandbox" {
  for_each = var.ingress_allows

  name        = each.key
  network     = google_compute_network.sandbox.self_link
  description = <<-EOF
    Allow ingress traffic to port ${each.value["port"]} on instances
    tagged with '${each.value["tag"]}' tag."
  EOF

  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["${each.value["port"]}"]
  }
  source_ranges = ["${each.value["cidr"]}"]
  target_tags   = [each.value["tag"]]
}
