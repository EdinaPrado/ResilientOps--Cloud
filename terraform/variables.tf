variable "cluster_name" {
  description = "Nome do cluster kind"
  type        = string
  default     = "resilientops"
}

variable "node_image" {
  description = "Imagem do node do kind (define a versão do Kubernetes)"
  type        = string
  default     = "kindest/node:v1.31.0"
}

variable "node_port" {
  description = "NodePort do Service do app, exposto na mesma porta do host (localhost:<porta>)"
  type        = number
  default     = 30000
}

variable "kubeconfig_path" {
  description = "Onde salvar o kubeconfig. Fica FORA do repositório, pois contém a chave privada."
  type        = string
  default     = "~/.kube/resilientops-config"
}

variable "install_metrics_server" {
  description = "Instalar o metrics-server (necessário para o HPA e para o kubectl top)"
  type        = bool
  default     = true
}
