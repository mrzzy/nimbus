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

variable "secret_keys" {
  type        = set(string)
  description = <<-EOF
    Keys used to identify secrets specified in 'secrets' var.
    Each key should correspond to an entry in the 'secrets' var.
  EOF
  default     = []
}

variable "secrets" {
  type = map(object({
    namespace = optional(string, "default"),
    name      = string,
    type      = optional(string, "Opaque"),
    data      = map(string)
  }))
  sensitive   = true
  description = "Map of K8s Secrets to create in the cluster within the given namespace."
  default     = {}
}
