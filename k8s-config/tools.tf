# metrics-server (enable "kubectl top nodes" command)
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.11.0"
  namespace  = "kube-system"
  values     = [file("manifests/metrics-server.yaml")]
}

# external-dns (add DNS record automatically)
resource "helm_release" "external_dns" {
  name             = "external-dns"
  repository       = "https://kubernetes-sigs.github.io/external-dns/"
  chart            = "external-dns"
  version          = "1.13.1"
  namespace        = var.tools_namespace
  create_namespace = true
  values           = [file("manifests/external-dns.yaml")]

  # Applying Cloudflare token at envvar from container job
  set {
    name  = "env[0].name"
    value = "CF_API_TOKEN"
  }

  set_sensitive {
    name  = "env[0].value"
    value = var.cloudflare_api_token
  }
}

# cert-manager (creates valid certificates for ingresses)
resource "helm_release" "cert_manager" {
  depends_on = [helm_release.external_dns]
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.13.2"
  namespace  = var.tools_namespace
  values     = [file("manifests/cert-manager.yaml")]

  # Changing default namespace
  set {
    name  = "global.leaderElection.namespace"
    value = var.tools_namespace
  }

  # Defined namespace for Issuer
  set {
    name  = "clusterResourceNamespace"
    value = var.tools_namespace
  }
}

# nginx-controller (Ingress)
resource "helm_release" "nginx_controller" {
  depends_on = [kubectl_manifest.letsencrypt_cluster_issuer]
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.8.2"
  namespace  = var.tools_namespace
  values     = [file("manifests/ingress-nginx.yaml")]
}

# clusterIssuer install (Let's Encrypt certificate signer)
resource "kubectl_manifest" "letsencrypt_cluster_issuer" {
  depends_on = [helm_release.cert_manager]
  yaml_body  = file("manifests/clusterissuer-letsencrypt.yaml")
}

# Getting docker credential to access DO's containter registry
resource "digitalocean_container_registry_docker_credentials" "ctf" {
  registry_name = data.terraform_remote_state.k8s_cluster.outputs.container_registry
}

# Creates "challenges" namespace
resource "kubernetes_namespace" "challenges" {
  metadata {
    name = "challenges"
  }
}

# Deploying docker credential as secret into namespace "challenges"
resource "kubernetes_secret" "ctf_container_registry_secret" {
  depends_on = [kubernetes_namespace.challenges]
  metadata {
    name      = "ctf-registry-creds"
    namespace = kubernetes_namespace.challenges.metadata[0].name
  }

  data = {
    ".dockerconfigjson" = digitalocean_container_registry_docker_credentials.ctf.docker_credentials
  }
  type = "kubernetes.io/dockerconfigjson"
}

# Adding kubeconfig into gitlab internal variables to be used during build/deploy (only testing)
resource "gitlab_group_variable" "kubeconfig_gitlab" {
  depends_on = [data.terraform_remote_state.k8s_cluster]
  group      = data.gitlab_group.fireshellctfteam_id.id
  key        = "kubeconfig"
  value      = data.digitalocean_kubernetes_cluster.fs-cluster.kube_config[0].raw_config
}

# Adding docker credential into gitlab to be used during build/deploy (only testing)
resource "gitlab_group_variable" "docker_creds_gitlab" {
  depends_on = [digitalocean_container_registry_docker_credentials.ctf]
  group      = data.gitlab_group.fireshellctfteam_id.id
  key        = "docker_creds"
  value      = digitalocean_container_registry_docker_credentials.ctf.docker_credentials
}