#
# Nimbus
# Terraform Deployment: GCE Shared Resources
#

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
  description = "Allow ingress traffic to instances tagged with '${each.key}' tag."

  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["${each.value}"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = [each.key]
}

# enroll project-wide ssh key for ssh access to VMs
resource "google_compute_project_metadata_item" "ssh_keys" {
  key   = "ssh-keys"
  value = "mrzzy:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBrfd982D9iQVTe2VecUncbgysh/XsZb4YyOhCSSAAtr mrzzy"
}
