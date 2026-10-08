provider "kind" {}

# Cluster Kubernetes local (kind), com o NodePort do app exposto em localhost
resource "kind_cluster" "this" {
  name            = var.cluster_name
  node_image      = var.node_image
  wait_for_ready  = true
  kubeconfig_path = pathexpand(var.kubeconfig_path)

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"

      extra_port_mappings {
        container_port = var.node_port
        host_port      = var.node_port
        protocol       = "TCP"
      }
    }
  }
}

# O Helm se conecta ao cluster recém-criado usando as credenciais do próprio recurso
provider "helm" {
  kubernetes {
    host                   = kind_cluster.this.endpoint
    cluster_ca_certificate = kind_cluster.this.cluster_ca_certificate
    client_certificate     = kind_cluster.this.client_certificate
    client_key             = kind_cluster.this.client_key
  }
}

# metrics-server: fornece CPU/memória dos pods para o HPA.
# No kind é preciso --kubelet-insecure-tls (certificados do kubelet são autoassinados).
resource "helm_release" "metrics_server" {
  count = var.install_metrics_server ? 1 : 0

  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"

  set {
    name  = "args[0]"
    value = "--kubelet-insecure-tls"
  }

  depends_on = [kind_cluster.this]
}
