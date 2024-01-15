# versions.tf: where all versions from Terraform and providers used during the process need to be declared

terraform {
  required_version = ">= 1.1.0"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.30.0"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "16.6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
  }
}