#
# Nimbus
# Terraform Deployment: Google Cloud Platform
#

terraform {
  required_version = ">=1.1.0, <1.2.0"
}

provider "google" {
  project = "mrzzy-sandbox"
  region  = "asia-southeast1"
  zone    = "asia-southeast1-c"
}
