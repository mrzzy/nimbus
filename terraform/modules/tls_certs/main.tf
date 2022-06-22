#
# Nimbus
# Terraform Deployment: TLS Certificates
#

terraform {
  required_providers {
    acme = {
      source  = "vancluever/acme"
      version = ">=2.9.0, <2.10.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">=3.4.0, <3.5.0"
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

# issue tls certificate via ACME
resource "acme_certificate" "cert" {
  account_key_pem           = acme_registration.register.account_key_pem
  common_name               = var.common_name
  subject_alternative_names = var.domains

  key_type = "P384" # ECDSA 384 bit key
  # don't takedown services relying on this cert if this terraform resource is destroyed
  revoke_certificate_on_destroy = false

  dns_challenge {
    provider = "gcloud"
    config = {
      GCE_PROJECT = var.gcp_project_id
    }
  }
}
