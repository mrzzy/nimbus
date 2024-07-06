#
# Nimbus
# Terraform Deployment: TLS ACME
#

terraform {
  required_providers {
    acme = {
      source  = "vancluever/acme"
      version = "< 2.24.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "< 4.0.6"
    }
  }
}

# register an account with the ACME server to issue TLS certificates given private key
resource "tls_private_key" "account" {
  algorithm = "RSA"
}

resource "acme_registration" "register" {
  account_key_pem = tls_private_key.account.private_key_pem
  email_address   = "program.nom@gmail.com"
}

# issue tls certificate via ACME using the DNS-01 challenge
resource "acme_certificate" "cert" {
  account_key_pem           = acme_registration.register.account_key_pem
  common_name               = var.common_name
  subject_alternative_names = var.domains

  key_type = "P384" # ECDSA 384 bit key
  # don't takedown services relying on this cert if this terraform resource is destroyed
  revoke_certificate_on_destroy = false

  dns_challenge {
    provider = var.dns_provider
  }
}
