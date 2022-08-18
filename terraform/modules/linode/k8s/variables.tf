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

variable "tls_certs" {
  type        = map(map(string))
  description = <<-EOF
    Map of TLS certificates to add to the K8s cluster as K8s secrets.

    Encodes the given Map of shape into K8s secrets & applies them into the cluster
    in the specified K8s namespace. The key of the given Map is used as the
    K8s secrets's name while the value should be a nested map in the following shape:
    {
      "namespace" = "<K8S NAMESPACE>"
      "cert" = "<FULL CHAIN TLS CERT PEM>"
    }

    Only the 'namespace' key is optional in the given map. If no 'namespace' key
    is provided, the k8s secret will be deployed to the 'default' namespace.
  EOF
}

variable "tls_keys" {
  type        = map(string)
  sensitive   = true
  description = <<-EOF
    Map of TLS private keys of the TLS certificates added in 'tls_certs' var.

    The given map should have a the same key as its corresponding entry in `tls_certs`
    and the value should be a PEM encoded TLS private key.
  EOF
}

variable "s3_csi" {
  type = object({
    s3_endpoint   = string,
    access_key_id = string,
    access_key    = string,
  })
  sensitive   = true
  default     = null
  description = <<EOF
    Credentials to pass to S3 CSI to provision Persistent Volumes on S3-compatible storage.

    Passes the given config & credentials to the S3 CSI by applying a 'csi-s3-secret'
    K8s Secret on the 'kube-system' namespace in the K8s Cluster.
  EOF
}
