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

output "k8s_singapore_kubeconfig" {
  value       = linode_lke_cluster.singapore.kubeconfig
  description = "Base64 encoded kubeconfig used to connect to the created LKE cluster"
  sensitive   = true
}

output "bastion_ip" {
  value       = module.bastion_singapore.wireguard_ip
  description = "IP address of the bastion host"
}
