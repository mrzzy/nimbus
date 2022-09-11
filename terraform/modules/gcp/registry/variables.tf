#
# Nimbus
# Container Registry
# Input Variables
#

variable "region" {
  type        = string
  description = "GCP region to deploy in the Docker Registry in."
}

variable "name" {
  type        = string
  description = "Name of the Container Registry to create."
}

variable "allow_writers" {
  type        = list(string)
  description = "List of IAM members allowed to push / pull from the Container Registry."
  default     = []
}

variable "allow_readers" {
  type        = list(string)
  description = "List of IAM members allowed pull from the Container Registry."
  default     = []
}
