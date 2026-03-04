resource "kubernetes_namespace_v1" "api_namespace" {
  metadata {
    name = "apis"
  }
}

resource "kubernetes_namespace_v1" "portals_namespace" {
  metadata {
    name = "webpages"
  }
}

resource "kubernetes_namespace_v1" "lakehouse_namespace" {
  metadata {
    name = "lakehouse"
  }
}

resource "kubernetes_namespace_v1" "llms_namespace" {
  metadata {
    name = "llms"
  }
}

resource "kubernetes_namespace_v1" "observability_namespace" {
  metadata {
    name = "observability"
  }
}
