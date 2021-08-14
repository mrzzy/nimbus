#
# nimbus
# terraform deploy for wasabi storage
# outputs
#

output "tiddlywiki_access_key_id" {
  description = "Tiddlywiki Service Account Access Key ID"
  value       = wasabi_access_key.tiddlywiki_sa_key.id
}

output "tiddlywiki_access_key_secret" {
  description = "Tiddlywiki Service Account Secret Key"
  value       = wasabi_access_key.tiddlywiki_sa_key.secret
  sensitive   = true
}
