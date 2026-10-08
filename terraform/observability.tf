variable "install_observability" {
  description = "Instalar o kube-prometheus-stack (Prometheus, Alertmanager e Grafana)"
  type        = bool
  default     = true
}

variable "kube_prometheus_stack_version" {
  description = "Versão do chart. null instala a mais recente; depois fixe a versão instalada (helm list -n monitoring)."
  type        = string
  default     = null
}

# Prometheus + Alertmanager + Grafana + kube-state-metrics (e o Prometheus Operator, que
# fornece os CRDs ServiceMonitor e PrometheusRule usados em k8s/monitoring/).
resource "helm_release" "kube_prometheus_stack" {
  count = var.install_observability ? 1 : 0

  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = var.kube_prometheus_stack_version
  namespace        = "monitoring"
  create_namespace = true
  timeout          = 900

  values = [
    yamlencode({
      # Componentes que o kind não expõe (ou que o WSL não suporta bem): evitam alertas falsos
      nodeExporter          = { enabled = false }
      kubeEtcd              = { enabled = false }
      kubeScheduler         = { enabled = false }
      kubeControllerManager = { enabled = false }
      kubeProxy             = { enabled = false }

      defaultRules = {
        rules = {
          etcd                   = false
          kubeControllerManager  = false
          kubeSchedulerAlerting  = false
          kubeSchedulerRecording = false
          kubeProxy              = false
        }
      }

      prometheus = {
        prometheusSpec = {
          retention = "12h"
          # Sem estes quatro, o Prometheus só enxerga ServiceMonitors/regras com o
          # label "release=kube-prometheus-stack". Assim ele enxerga os do projeto.
          serviceMonitorSelectorNilUsesHelmValues = false
          podMonitorSelectorNilUsesHelmValues     = false
          probeSelectorNilUsesHelmValues          = false
          ruleSelectorNilUsesHelmValues           = false
          resources = {
            requests = { cpu = "100m", memory = "400Mi" }
            limits   = { memory = "1Gi" }
          }
        }
      }

      alertmanager = {
        alertmanagerSpec = {
          resources = {
            requests = { cpu = "10m", memory = "32Mi" }
          }
        }
      }

      grafana = {
        # Carrega automaticamente ConfigMaps com o label grafana_dashboard=1
        sidecar = {
          dashboards = {
            enabled         = true
            label           = "grafana_dashboard"
            labelValue      = "1"
            searchNamespace = "ALL"
          }
        }
      }
    })
  ]

  depends_on = [kind_cluster.this]
}

output "observability_access" {
  description = "Como abrir as interfaces (rode cada comando em um terminal)"
  value = var.install_observability ? {
    grafana       = "kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80"
    prometheus    = "kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090"
    alertmanager  = "kubectl port-forward -n monitoring svc/kube-prometheus-stack-alertmanager 9093:9093"
    grafana_senha = "kubectl get secret -n monitoring kube-prometheus-stack-grafana -o jsonpath=\"{.data.admin-password}\" | base64 -d; echo"
  } : {}
}
