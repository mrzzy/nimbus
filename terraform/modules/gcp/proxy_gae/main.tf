#
# Nimbus
# Terraform Module
# GAEProxy on GCP
#

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=4.22.0"
    }
  }
}

locals {
  # google app engine will route requests to the proxy via hostname:
  # "<PROJECT>.<REGION>.r.appspot.com"
  # https://cloud.google.com/appengine/docs/legacy/standard/python/how-requests-are-routed
  proxy_host = "${var.project_id}.${var.gae_region_id}.r.appspot.com"
}
resource "google_app_engine_flexible_app_version" "v1" {
  version_id                = "v1"
  runtime                   = "custom"
  service                   = "default"
  delete_service_on_destroy = true

  deployment {
    container {
      image = var.container
    }
  }
  env_variables = {
    PROXY_SPEC = var.proxy_spec
    HOSTNAME   = local.proxy_host
  }
  liveness_check {
    path = "/health"
  }
  readiness_check {
    path = "/health"
  }
  manual_scaling {
    instances = 1
  }

  lifecycle {
    ignore_changes = [
      # GAE automatically assigns service to the default service account
      service_account,
      # whether the service is serving requests is controlled at the application level
      serving_status
    ]
  }
}
