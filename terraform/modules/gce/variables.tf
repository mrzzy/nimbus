#
# Nimbus
# Terraform Deployment: GCE Shared Resources
# Input Variables
#

variable "allow_ssh_tag" {
  type        = string
  description = "Allow SSH traffic on port 22 to instances this GCE Metadata tag."
}
