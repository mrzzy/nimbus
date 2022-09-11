#
# Nimbus
# Container Registry
# Outputs
#

output "repo_prefix" {
  description = "Repository prefix in tags of containers pushed to this repository."
  value       = "${google_artifact_registry_repository.repo.location}-docker.pkg.dev/${google_artifact_registry_repository.repo.project}/${google_artifact_registry_repository.repo.repository_id}"
}
