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

# allow SSH traffic to instances tagged with "allow-ssh" tag.
resource "google_compute_firewall" "sandbox" {
  name        = "allow-ssh"
  network     = google_compute_network.sandbox.self_link
  description = "allow SSH traffic to instances tagged with 'allow-ssh' tag."

  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = [var.allow_ssh_tag]
}

# enroll project-wide ssh key for ssh access to VMs
resource "google_compute_project_metadata_item" "ssh_keys" {
  key   = "ssh-keys"
  value = "mrzzy:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBrfd982D9iQVTe2VecUncbgysh/XsZb4YyOhCSSAAtr mrzzy"
}
