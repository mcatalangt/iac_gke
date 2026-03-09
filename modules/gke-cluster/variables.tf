variable "project_id" {
  description = "ID del proyecto GCP"
  type        = string
}

variable "region" {
  description = "Región de GCP para el clúster"
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "Nombre base para el clúster GKE"
  type        = string
  default     = "gke"
}



variable "environment" {
  description = "Nombre base para el env GKE"
  type        = string
  default     = "dev"
}

variable "deploy_rag_stack" {
  description = "Despliega recursos adicionales de GPU si el Stack RAG está habilitado"
  type        = bool
  default     = false
}
