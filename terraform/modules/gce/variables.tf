#
# Nimbus
# Terraform Deployment: GCE Shared Resources
# Input Variables
#

variable "ingress_allows" {
  type        = map(list(string))
  description = <<-EOF
  List of ingress allow rules to create the firewall.
  Expressed as map of <tag> = [<cidr>, <port>].

  This allows ingress traffic from the IPs in the CIDR range to the specified
  port on GCE instances tagged with the specified GCE Metadata tag.
  EOF
}
