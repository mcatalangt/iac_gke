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
}

resource "helm_release" "loki" {
  name             = "loki"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki"
  namespace        = "observability"
  create_namespace = true

  set {
    name  = "deploymentMode"
    value = "SingleBinary"
  }
  set {
    name  = "singleBinary.replicas"
    value = "1"
  }
  # Disable scalable targets explicitly
  set {
    name  = "read.replicas"
    value = "0"
  }
  set {
    name  = "write.replicas"
    value = "0"
  }
  set {
    name  = "backend.replicas"
    value = "0"
  }
  set {
    name  = "loki.auth_enabled"
    value = "false"
  }
  set {
    name  = "loki.commonConfig.replication_factor"
    value = "1"
  }
  set {
    name  = "loki.storage.type"
    value = "filesystem"
  }
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
