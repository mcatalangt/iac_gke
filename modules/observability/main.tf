# Repository setup
resource "helm_release" "grafana" {
  count            = var.deploy_observability_stack ? 1 : 0
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
  count            = var.deploy_observability_stack ? 1 : 0
  name             = "loki"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki"
  namespace        = "observability"
  create_namespace = true

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
    value = "filesystem" # Idealmente usar GCS en producción
  }
}

resource "helm_release" "tempo" {
  count            = var.deploy_observability_stack ? 1 : 0
  name             = "tempo"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "tempo"
  namespace        = "observability"
  create_namespace = true
}

resource "helm_release" "mimir" {
  count            = var.deploy_observability_stack ? 1 : 0
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
