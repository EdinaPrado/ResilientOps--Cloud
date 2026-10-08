output "cluster_name" {
  description = "Nome do cluster kind"
  value       = kind_cluster.this.name
}

output "kubectl_context" {
  description = "Contexto do kubectl para este cluster"
  value       = "kind-${kind_cluster.this.name}"
}

output "kubeconfig_path" {
  description = "Arquivo de kubeconfig gerado (não versionar)"
  value       = pathexpand(var.kubeconfig_path)
}

output "app_url" {
  description = "URL do app depois do kubectl apply -f k8s/deployment.yaml"
  value       = "http://localhost:${var.node_port}"
}
