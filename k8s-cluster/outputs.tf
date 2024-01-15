# outputs.tf: after applying the settings, Terraform prints out these informations in output command, allowing terraform_remote_state
# resource to get them and use in another state.

# DO Token
output "do_token_output" {
  description = "Digital Ocean API Token"
  value       = var.do_token
  sensitive   = true
}

# Container Registry name
output "container_registry" {
  description = "Container Registry name"
  value       = digitalocean_container_registry.ctf.name
}