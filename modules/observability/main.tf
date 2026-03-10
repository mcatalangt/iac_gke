# Repository setup
resource "helm_release" "grafana" {
  name             = "grafana"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "grafana"
  namespace        = "observability"
  create_namespace = true

  set {
    name  = "adminPassword"
    value = "admin" # TODO: En producción, usar Secret Manager o al menos una variable fuerte.
  }

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
}

resource "helm_release" "loki" {
  name             = "loki"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki"
  namespace        = "observability"
  create_namespace = true

  values = [
    yamlencode({
      deploymentMode = "SingleBinary"
      loki = {
        auth_enabled = false
        commonConfig = {
          replication_factor = 1
        }
        storage = {
          type = "filesystem"
        }
        useTestSchema = true
      }
      singleBinary = {
        replicas = 1
      }
      read = {
        replicas = 0
      }
      write = {
        replicas = 0
      }
      backend = {
        replicas = 0
      }
    })
  ]
}

resource "helm_release" "tempo" {
  name             = "tempo"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "tempo"
  namespace        = "observability"
  create_namespace = true
}

resource "helm_release" "mimir" {
  name             = "mimir"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "mimir-distributed"
  namespace        = "observability"
  create_namespace = true

  # Set minimal requirements to avoid issues in basic dev environment
  set {
    name  = "minio.enabled"
    value = "true"
  }
  set {
    name  = "mimir.structuredConfig.multitenancy_enabled"
    value = "false"
  }
}

resource "helm_release" "oncall" {
  name             = "oncall"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "oncall"
  namespace        = "observability"
  create_namespace = true

  # Override the image tags because the default ones in the chart are no longer on Docker Hub (Bitnami pruning)
  set {
    name  = "redis.image.tag"
    value = "latest"
  }
  set {
    name  = "rabbitmq.image.registry"
    value = "docker.io"
  }
  set {
    name  = "rabbitmq.image.repository"
    value = "rabbitmq"
  }
  set {
    name  = "rabbitmq.image.tag"
    value = "3.12-management"
  }
  set {
    name  = "mariadb.image.tag"
    value = "latest"
  }
}

resource "helm_release" "pyroscope" {
  name             = "pyroscope"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "pyroscope"
  namespace        = "observability"
  create_namespace = true
}

resource "helm_release" "alloy" {
  name             = "alloy"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "alloy"
  namespace        = "observability"
  create_namespace = true

  values = [
    yamlencode({
      alloy = {
        configMap = {
          content = <<-EOT
            faro.receiver "default" {
              extra_log_labels = {
                app = "frontend",
              }
              server {
                listen_address = "0.0.0.0"
                listen_port = 12347
              }
              output {
                logs = [loki.write.default.receiver]
              }
            }

            loki.write "default" {
              endpoint {
                url = "http://loki.observability.svc.cluster.local:3100/loki/api/v1/push"
              }
            }
          EOT
        }
      }
    })
  ]
}
