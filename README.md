# Introduction

This repository has Terraform code to spin up into Digital Ocean (DO) the app CTFd (platform for host IT challenges from many categories), by using IoC concepts (Infrastructure as Code). The code itself is splitted in two steps:

* Cluster Kubernetes + Container Registry
* All Kubernetes settings:
  * external-dns - it sets automatically every requests from Kubernetes manifests to DNS Server supported (in this case, Cloudflare)
  * cert-manager - it manages requested certificates in one single PKI chain (using Let's Encrypt)
  * nginx-controller - reverse proxy that forwards outside requests to internal services by Load Balancer set into Kubernetes cluster
  * CTFd - CTF platform to register challenges
  * Some custom scripts (i.e. adding CTFd theme)