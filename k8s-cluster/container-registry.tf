# Container registry for storing images challenges
resource "digitalocean_container_registry" "ctf" {
  name                   = "ctf"
  subscription_tier_slug = "basic"
  region                 = var.region
}
