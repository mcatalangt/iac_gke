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

  values = [
    yamlencode({
      "grafana.ini" = {
        feature_toggles = {
          enable = "tempoApmTable tempoServiceGraph traceqlEditor metricsSummary"
        }
      }
      datasources = {
        "datasources.yaml" = {
          apiVersion = 1
          datasources = [
            {
              name      = "Loki"
              uid       = "Loki"
              type      = "loki"
              access    = "proxy"
              url       = "http://loki.observability.svc.cluster.local:3100"
              isDefault = true
            },
            {
              name   = "Tempo"
              type   = "tempo"
              access = "proxy"
              url    = "http://tempo.observability.svc.cluster.local:3200"
              jsonData = {
                nodeGraph = {
                  enabled = true
                }
                serviceMap = {
                  datasourceUid = "Mimir"
                }
                search = {
                  hide = false
                }
                serviceGraph = {
                  enabled       = true
                  datasourceUid = "Mimir"
                  query = {
                    requestTotal           = "traces_service_graph_request_total"
                    requestFailedTotal     = "traces_service_graph_request_failed_total"
                    requestDurationSeconds = "traces_service_graph_request_server_seconds"
                  }
                }
                tracesToLogs = {
                  datasourceUid   = "Loki"
                  tags            = ["target", "cluster", "namespace", "pod", "container"]
                  filterByTraceID = true
                }
                tracesToMetrics = {
                  datasourceUid = "Mimir"
                  tags          = [{ key = "service.name", value = "service" }]
                }
                tracesToProfiles = {
                  datasourceUid = "Pyroscope"
                  tags          = [{ key = "service.name", value = "service" }]
                }
              }
            },
            {
              name   = "Mimir"
              uid    = "Mimir"
              type   = "prometheus"
              access = "proxy"
              url    = "http://mimir-query-frontend.observability.svc.cluster.local:8080/prometheus"
            },
            {
              name   = "Pyroscope"
              uid    = "Pyroscope"
              type   = "grafana-pyroscope-datasource"
              access = "proxy"
              url    = "http://pyroscope.observability.svc.cluster.local:4040"
            }
          ]
        }
      }
    })
  ]
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

  values = [
    yamlencode({
      tempo = {
        metricsGenerator = {
          enabled        = true
          remoteWriteUrl = "http://mimir-distributor.observability.svc.cluster.local:8080/api/v1/push"
        }
        overrides = {
          defaults = {
            metrics_generator = {
              processors = ["service-graphs", "span-metrics", "local-blocks"]
            }
          }
        }
      }
      queryFrontend = {
        query = {
          enabled = true
        }
        mcp_server = {
          enabled = true
        }
      }
    })
  ]
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

  # Override registries to use AWS Public ECR since Bitnami prunes older tags from Docker Hub.
  set {
    name  = "redis.image.registry"
    value = "public.ecr.aws"
  }
  set {
    name  = "redis.image.tag"
    value = "6.2-debian-11"
  }
  set {
    name  = "rabbitmq.image.registry"
    value = "public.ecr.aws"
  }
  set {
    name  = "rabbitmq.image.repository"
    value = "bitnami/rabbitmq"
  }
  set {
    name  = "rabbitmq.image.tag"
    value = "3.12-debian-11"
  }
  set {
    name  = "mariadb.image.registry"
    value = "public.ecr.aws"
  }
  set {
    name  = "mariadb.image.tag"
    value = "10.11-debian-11"
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
        extraPorts = [
          {
            name       = "faro"
            port       = 12347
            targetPort = 12347
            protocol   = "TCP"
          },
          {
            name       = "otlp-grpc"
            port       = 4317
            targetPort = 4317
            protocol   = "TCP"
          },
          {
            name       = "otlp-http"
            port       = 4318
            targetPort = 4318
            protocol   = "TCP"
          },
          {
            name       = "pyroscope"
            port       = 4040
            targetPort = 4040
            protocol   = "TCP"
          }
        ]
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
                logs   = [loki.write.default.receiver]
                traces = [otelcol.exporter.otlp.tempo.input]
              }
            }

            otelcol.receiver.otlp "default" {
              grpc {
                endpoint = "0.0.0.0:4317"
              }
              http {
                endpoint = "0.0.0.0:4318"
              }
              output {
                metrics = [otelcol.exporter.prometheus.default.input]
                logs    = [otelcol.exporter.loki.default.input]
                traces  = [otelcol.exporter.otlp.tempo.input]
              }
            }

            pyroscope.receive_http "default" {
              http {
                listen_address = "0.0.0.0"
                listen_port = 4040
              }
              forward_to = [pyroscope.write.default.receiver]
            }

            pyroscope.write "default" {
              endpoint {
                url = "http://pyroscope.observability.svc.cluster.local:4040"
              }
            }

            otelcol.exporter.prometheus "default" {
              forward_to = [prometheus.remote_write.mimir.receiver]
            }

            prometheus.remote_write "mimir" {
              endpoint {
                url = "http://mimir-distributor.observability.svc.cluster.local:8080/api/v1/push"
              }
            }

            otelcol.exporter.loki "default" {
              forward_to = [loki.write.default.receiver]
            }

            loki.write "default" {
              endpoint {
                url = "http://loki.observability.svc.cluster.local:3100/loki/api/v1/push"
              }
            }

            otelcol.exporter.otlp "tempo" {
              client {
                endpoint = "tempo.observability.svc.cluster.local:4317"
                tls {
                  insecure = true
                }
              }
            }
          EOT
        }
      }
    })
  ]
}
