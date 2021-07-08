#
# nimbus
# terraform deploy for linode cloud
# output
#

output "k8s_singapore_id" {
  value       = linode_lke_cluster.singapore.id
  description = "ID of Linode LKE Cluster in Singapore"
}

output "k8s_singapore_status" {
  value       = linode_lke_cluster.singapore.status
  description = "Status of Linode LKE Cluster in Singapore"
}
