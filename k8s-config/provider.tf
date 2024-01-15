# DO provider. Here I'm getting the output from another state
provider "digitalocean" {
  token = data.terraform_remote_state.k8s_cluster.outputs.do_token_output
}

# Used for applying manifests
provider "kubectl" {
  host  = data.digitalocean_kubernetes_cluster.fs-cluster.endpoint
  token = data.digitalocean_kubernetes_cluster.fs-cluster.kube_config[0].token
  cluster_ca_certificate = base64decode(
    data.digitalocean_kubernetes_cluster.fs-cluster.kube_config[0].cluster_ca_certificate
  )
  load_config_file = false
}

# Used for creating resources in the Kubernetes cluster
provider "kubernetes" {
  host  = data.digitalocean_kubernetes_cluster.fs-cluster.endpoint
  token = data.digitalocean_kubernetes_cluster.fs-cluster.kube_config[0].token
  cluster_ca_certificate = base64decode(
    data.digitalocean_kubernetes_cluster.fs-cluster.kube_config[0].cluster_ca_certificate
  )
}

# Install apps using helm
provider "helm" {
  kubernetes {
    host  = data.digitalocean_kubernetes_cluster.fs-cluster.endpoint
    token = data.digitalocean_kubernetes_cluster.fs-cluster.kube_config[0].token
    cluster_ca_certificate = base64decode(
      data.digitalocean_kubernetes_cluster.fs-cluster.kube_config[0].cluster_ca_certificate
    )
  }
}

# Used for creating random passwords
provider "random" {}

# Used for manage local files
provider "local" {}

# Used for manage gitlab
provider "gitlab" {
  token = var.gitlab_token
}