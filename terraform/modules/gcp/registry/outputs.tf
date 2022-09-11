#
# Nimbus
# Container Registry
# Outputs
#

output "repo_prefix" {
  description = <<-EOF
  Repository prefix in containers tags pushed to this Container Registry.

  Containers should be tagged & pushed  with '<repo_prefix>/<NAME>' to target this
  Containers Registry.
  EOF
  value       = "${google_artifact_registry_repository.repo.location}-docker.pkg.dev/${google_artifact_registry_repository.repo.project}/${google_artifact_registry_repository.repo.repository_id}"
}
