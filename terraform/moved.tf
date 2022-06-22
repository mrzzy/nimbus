#
# Nimbus
# Terraform Deployment
# Moved Tombstones
#

# Tombstones for resources moved into child modules
moved {
  from = google_compute_disk.warp_disk
  to   = module.warp_vm.google_compute_disk.warp_disk
}

moved {
  from = google_compute_network.sandbox
  to   = module.gce.google_compute_network.sandbox
}

moved {
  from = google_compute_firewall.sandbox
  to   = module.gce.google_compute_firewall.sandbox
}

moved {
  from = google_compute_project_metadata_item.ssh_keys
  to   = module.gce.google_compute_project_metadata_item.ssh_keys
}
