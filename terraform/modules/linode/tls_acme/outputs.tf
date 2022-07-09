#
# Nimbus
# Terraform Deployment: TLS ACME
# Output variables
#

output "private_key" {
  description = "Issued TLS certificate's private key in PEM format."
  value       = acme_certificate.cert.private_key_pem
}

output "full_chain_cert" {
  description = <<-EOF
  Issued TLS certificate, with intermediate certificates to form the full
  certificate chain, rendered in PEM format.
  EOF
  value       = "${acme_certificate.cert.certificate_pem}${acme_certificate.cert.issuer_pem}"
}
