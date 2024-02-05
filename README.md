# Introduction

This Gitlab template has Terraform code to spin up into Digital Ocean (DO) the app CTFd (platform for host IT challenges from many categories) and all the settings related to Gitlab pipeline, by using IoC concepts (Infrastructure as Code). The code itself is splitted in two steps:

* Cluster Kubernetes + Container Registry
* All Kubernetes settings:
  * external-dns - it sets automatically every requests from Kubernetes manifests to DNS Server supported (in this case, Cloudflare)
  * cert-manager - it manages requested certificates in one single PKI chain (using Let's Encrypt)
  * nginx-controller - reverse proxy that forwards outside requests to internal services by Load Balancer set into Kubernetes cluster
  * CTFd - CTF platform to register challenges
  * Some custom scripts (i.e. adding CTFd theme)

# How to install

* Push all these files to your Gitlab repository (main branch)
* Create a new branch for it
* Change something in the code
* Create a Merge Request (MR)

# Triggering the pipeline

There are three steps for applying the code:

* Infrastructure building
* Deploying apps, tools and general settings
* Infrastructure destroy

All those steps will be triggered only by creating a new branch (based on main) with a MR after. It's not needed to merge every time the MR for doing new changes, just push new changes from MR and wait the code do all the job for you.

# Instructions

All the code was commented out explaining what every single line mean.