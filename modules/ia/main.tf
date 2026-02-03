resource "helm_release" "qdrant" {
  name             = "qdrant"
  repository       = "https://qdrant.github.io/qdrant-helm"
  chart            = "qdrant"
  namespace        = "database"
  create_namespace = true
  values = [
      yamlencode({
        replicaCount = 1
        
        apiKey = var.qdrant_api_key
        
        persistence = {
          enabled          = true
          size             = "10Gi"
          storageClassName = "premium-rwo" # O el que estés usando
        }

        service = {
          type = "ClusterIP"
        }
      })
    ]

  
}