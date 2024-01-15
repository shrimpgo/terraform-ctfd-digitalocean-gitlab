# Loading settings from "Fireshell" project in DO
data "digitalocean_project" "fireshell" {}

# Registering created cluster into "Fireshell" project
resource "digitalocean_project_resources" "fireshell_resources" {
  project = data.digitalocean_project.fireshell.id
  resources = [
    digitalocean_kubernetes_cluster.fs_cluster.urn,
  ]
}