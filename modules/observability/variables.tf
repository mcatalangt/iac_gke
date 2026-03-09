variable "cluster_endpoint" {
  description = "The endpoint for the GKE cluster"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "The CA certificate for the GKE cluster"
  type        = string
}

variable "token" {
  description = "The access token for the GKE cluster"
  type        = string
}

variable "deploy_observability_stack" {
  description = "Boolean switch to deploy the Observability Stack (Grafana, Loki, Tempo, Mimir, etc.)"
  type        = bool
  default     = false
}
