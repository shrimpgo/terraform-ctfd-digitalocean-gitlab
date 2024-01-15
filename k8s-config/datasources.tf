# Importing state file from another state, located in gitlab
data "terraform_remote_state" "k8s_cluster" {
  backend = "http"
  config = {
    # The state is located in the same project
    address  = "https://gitlab.com/api/v4/projects/${var.CI_PROJECT_ID}/terraform/state/cluster"
    # In this case, I can take advantage from gitlab environment and use the same credential from running job
    username = "gitlab-ci-token"
    password = var.CI_JOB_TOKEN
  }
}

# Getting kubernetes cluster data for later using the credential
data "digitalocean_kubernetes_cluster" "fs-cluster" {
  name = "fireshell-cluster"
}

# Getting project ID from gitlab
data "gitlab_group" "fireshellctfteam_id" {
  full_path = "fireshellctfteam"
}