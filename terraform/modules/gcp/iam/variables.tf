#
# Nimbus
# Terraform Deployment: Identity & Access
#

variable "project" {
  type        = string
  description = "ID of the GCP project to create the IAM resources in."
}

variable "allow_gh_actions" {
  type        = list(string)
  description = <<-EOF
    Github repostories with Github Actions to create Workload Identity Pools for.

    This allows the use of Github OIDC tokens issued to Action Workflows to beta
    as credentials for authenticate with GCP.

    Repositories should be specified in the format: "<OWNER>/<REPO>".
  EOF
  default     = []
}
