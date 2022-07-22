#
# Nimbus
# Terraform Deployment: VPC Network
# Input Variables
#

variable "ingress_allows" {
  type        = map(map(string))
  description = <<-EOF
  List of ingress allow rules to create the firewall.
  Expressed as map of id = {
    tag = <tag>,
    cidr = <cidr>,
    port= <port>
  }.

  This allows ingress traffic from the IPs in the CIDR range to the specified
  port on GCE instances tagged with the specified GCE Metadata tag.
  EOF
}
