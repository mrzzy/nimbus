#
# Nimbus
# Container Registry
#

resource "google_artifact_registry_repository" "repo" {
  location      = var.region
  repository_id = lower(replace(var.name, " ", "-"))
  format        = "DOCKER"
}

resource "google_artifact_registry_repository_iam_binding" "reader" {
  repository = google_artifact_registry_repository.repo.name
  location   = google_artifact_registry_repository.repo.location

  for_each = {
    "roles/artifactregistry.reader" = var.allow_readers
    "roles/artifactregistry.writer" = var.allow_writers
  }
  role    = each.key
  members = each.value
}
