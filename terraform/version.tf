terraform {
  required_version = ">= 1.5"

  required_providers {
    # Mesmo provider e versão que o projeto já usava (ver .terraform.lock.hcl antigo)
    kind = {
      source  = "tehcyx/kind"
      version = "0.5.1"
    }
    # Usado para instalar o metrics-server (necessário para o HPA)
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.15"
    }
  }
}
