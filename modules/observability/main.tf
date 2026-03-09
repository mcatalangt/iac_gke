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
