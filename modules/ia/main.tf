resource "helm_release" "qdrant" {
  name             = "qdrant"
  repository       = "https://qdrant.github.io/qdrant-helm"
  chart            = "qdrant"
  namespace        = "database"
  create_namespace = true
  set {
    name  = "replicaCount"
    value = "1" 
        }
  set {
        name  = "persistence.enabled"
        value = "true"
    }
  set {
    name  = "persistence.storageClassName"
    value = "standard-rwo"
  }
  set {
    name  = "service.type"
    value = "LoadBalancer" 
  }

  
}