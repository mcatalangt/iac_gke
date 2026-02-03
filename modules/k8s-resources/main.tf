resource "kubernetes_namespace" "api_namespace" {
  metadata {
    name = "apis"
  }
}

resource "kubernetes_namespace" "portals_namespace" {
  metadata {
    name = "portals"
  }
}

resource "kubernetes_namespace" "lakehouse_namespace" {
  metadata {
    name = "lakehouse"
  }
}

resource "kubernetes_namespace" "vectordb_namespace" {
  metadata {
    name = "vectordb"
  }
}