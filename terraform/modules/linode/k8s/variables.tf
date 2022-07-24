#
# Nimbus
# Terraform Deployment: Linode Kubernetes Engine
# Input Variables
#

variable "region" {
  type        = string
  description = "Linode region to deploy the K8s cluster to "
}

variable "machine_type" {
  type        = string
  description = "Linode instance type to use when creating workers for K8s."
}

variable "n_workers" {
  type        = number
  description = "No. of worker nodes to create for K8s."
}
