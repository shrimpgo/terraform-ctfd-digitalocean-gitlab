# Creating cluster Kubernetes with 1 node
resource "digitalocean_kubernetes_cluster" "fs_cluster" {
  name    = "fireshell-cluster"
  region  = var.region
  version = "1.28.2-do.0"
  # Node definition
  node_pool {
    name       = "chall-pool"
    size       = "s-2vcpu-4gb" # Node with 2 vCPU and 4 GB RAM
    node_count = 2 # Number of nodes

    # Node with taint
    taint {
      key    = "chall"
      value  = "true"
      effect = "NoSchedule"
    }
  }
}

# Adding one more nodepool
resource "digitalocean_kubernetes_node_pool" "ctfd-pool" {
  cluster_id = digitalocean_kubernetes_cluster.fs_cluster.id
  name       = "ctfd-pool"
  size       = "s-2vcpu-4gb" # Node with 2 vCPU and 4 GB RAM
  node_count = 1

  # Node with taint
  taint {
    key    = "ctfd"
    value  = "true"
    effect = "NoSchedule"
  }
}