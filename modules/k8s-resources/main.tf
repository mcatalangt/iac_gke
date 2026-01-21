resource "kubernetes_namespace" "api_namespace" {
  metadata {
    name = "apis"
  }
}

resource "kubernetes_namespace" "engines_namespace" {
  metadata {
    name = "engines"
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

resource "kubernetes_namespace" "messaging_namespace" {
  metadata {
    name = "messaging"
  }
}