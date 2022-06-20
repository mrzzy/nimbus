#
# Nimbus
# Terraform Deployment: GCE Shared Resources
# Input Variables
#

variable "ingress_allows" {
  type        = map(number)
  description = <<-EOF
  List of ingress allow rules to create the firewall as map of <tag> = <port>.
  This allows ingress traffic from the internet to the specified port on
  GCE instances tagged with the specified GCE Metadata tag.
  EOF
}
