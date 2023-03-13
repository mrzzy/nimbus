#
# Nimbus
# Terraform Module
# GAEProxy on GCP
# Outputs
#

locals {
  # GAE region id is formed from the first character of each '-' delimited token
  gae_region_id = join("", [for token in split(var.region, "-") : substr(token, 0, 1)])
}

output "hostname" {
  description = "Hostname used to access GAEProxy based on how App Engine Routes requests."
  # GAE will route requests to the proxy via hostname:
  # "<PROJECT>.<REGION>.r.appspot.com"
  # https://cloud.google.com/appengine/docs/legacy/standard/python/how-requests-are-routed
  value = "${var.project_id}.${local.gae_region_id}.r.appspot.com"
}
