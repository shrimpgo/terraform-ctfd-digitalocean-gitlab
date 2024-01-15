# DO provider
provider "digitalocean" {
  # DO Token with right privileges. It has to be stored in gitlab variables
  token = var.do_token
}