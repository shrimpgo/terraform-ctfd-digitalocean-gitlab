# Creating volumes for CTFd uploads
resource "digitalocean_volume" "ctfd_uploads" {
  region                  = "sfo3"
  name                    = "ctfd-uploads"
  size                    = 20
  initial_filesystem_type = "ext4"
  description             = "Volume for upload files in CTFd"
}

# Creating volumes for MariaDB from CTFd
resource "digitalocean_volume" "ctfd_mariadb" {
  region                  = "sfo3"
  name                    = "ctfd-mariadb"
  size                    = 20
  initial_filesystem_type = "ext4"
  description             = "Volume for MariaDB for CTFd"
}

# Creating random passwords
resource "random_password" "mariadb_rootpassword" {
  length  = 32
  special = false
}

resource "random_password" "mariadb_password" {
  length  = 32
  special = false
}

resource "random_password" "mariadb_replicationpassword" {
  length  = 32
  special = false
}

resource "random_password" "redis_password" {
  length  = 32
  special = false
}

resource "random_password" "secret_key" {
  length  = 32
  special = false
}

resource "kubernetes_namespace" "ctfd" {
  metadata {
    name = "ctfd"
  }
}

# Applying upload PersistentVolume into Kubernetes
resource "kubectl_manifest" "pv_uploads" {
  depends_on = [kubernetes_namespace.ctfd]
  yaml_body  = <<YAML
kind: PersistentVolume
apiVersion: v1
metadata:
  name: pv-uploads
  annotations:
    # fake it by indicating this is provisioned dynamically, so the system
    # works properly
    pv.kubernetes.io/provisioned-by: dobs.csi.digitalocean.com
spec:
  storageClassName: do-block-storage-retain
  capacity:
    storage: 20Gi
  accessModes:
    - ReadWriteOnce
  csi:
    driver: dobs.csi.digitalocean.com
    fsType: ext4
    volumeHandle: ${digitalocean_volume.ctfd_uploads.id}
    volumeAttributes:
      com.digitalocean.csi/noformat: "true"
YAML
}

# Applying upload PersistentVolumeClaim into Kubernetes
resource "kubectl_manifest" "pvc_uploads" {
  depends_on = [kubectl_manifest.pv_uploads]
  yaml_body  = <<YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-uploads
  namespace: ctfd
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
  storageClassName: do-block-storage-retain
  volumeName: pv-uploads
YAML
}

# Applying MariaDB PersistentVolume into Kubernetes
resource "kubectl_manifest" "pv_mariadb" {
  depends_on = [kubernetes_namespace.ctfd]
  yaml_body  = <<YAML
kind: PersistentVolume
apiVersion: v1
metadata:
  name: pv-mariadb
  annotations:
    # fake it by indicating this is provisioned dynamically, so the system
    # works properly
    pv.kubernetes.io/provisioned-by: dobs.csi.digitalocean.com
spec:
  storageClassName: do-block-storage-retain
  capacity:
    storage: 20Gi
  accessModes:
    - ReadWriteOnce
  csi:
    driver: dobs.csi.digitalocean.com
    fsType: ext4
    volumeHandle: ${digitalocean_volume.ctfd_mariadb.id}
    volumeAttributes:
      com.digitalocean.csi/noformat: "true"
YAML
}

# Applying MariaDB PersistentVolumeClaim into Kubernetes
resource "kubectl_manifest" "pvc_mariadb" {
  depends_on = [kubectl_manifest.pv_mariadb]
  yaml_body  = <<YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-mariadb
  namespace: ctfd
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
  storageClassName: do-block-storage-retain
  volumeName: pv-mariadb
YAML
}

# Installing CTFd via helm
resource "helm_release" "ctfd" {
  depends_on = [helm_release.nginx_controller, kubectl_manifest.pvc_uploads, kubectl_manifest.pvc_mariadb]
  name       = "ctfd"
  chart      = "oci://ghcr.io/bman46/ctfd/ctfd"
  version    = "0.6.3"
  namespace  = "ctfd"
  values     = [file("manifests/ctfd.yaml")]

  # Applying all random passwords
  set_sensitive {
    name  = "redis.auth.password"
    value = random_password.redis_password.result
  }

  set_sensitive {
    name  = "mariadb.auth.rootPassword"
    value = random_password.mariadb_rootpassword.result
  }

  set_sensitive {
    name  = "mariadb.auth.password"
    value = random_password.mariadb_password.result
  }

  set_sensitive {
    name  = "mariadb.auth.replicationPassword"
    value = random_password.mariadb_replicationpassword.result
  }

  set_sensitive {
    name  = "env.open.SECRET_KEY"
    value = random_password.secret_key.result
  }
}

# Creating kubeconfig file to use for access Kubernetes cluster
resource "local_sensitive_file" "kubeconfig" {
  depends_on = [helm_release.ctfd]
  content    = data.digitalocean_kubernetes_cluster.fs-cluster.kube_config[0].raw_config
  filename   = "/tmp/kubeconfig.yaml"
}

# Running script to copy CTFd theme to container Pod
resource "null_resource" "copy_fireshell_theme" {
  depends_on = [local_sensitive_file.kubeconfig]
  triggers = {
    # This option makes this resource to run every time we run terraform apply
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "/bin/sh scripts/copy-fireshell-theme.sh /tmp/kubeconfig.yaml"
  }
}