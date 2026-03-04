resource "kubernetes_namespace_v1" "api_namespace" {
  metadata {
    name = "apis"
  }
}

resource "kubernetes_namespace_v1" "portals_namespace" {
  metadata {
    name = "portals"
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
