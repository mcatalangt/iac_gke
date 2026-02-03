variable "qdrant_api_key" {
  description = "La clave secreta para proteger la base de datos Qdrant"
  type        = string
  sensitive   = true 
}
variable "cluster_endpoint" {
  type = string
}

variable "token" {
  type      = string
  sensitive = true
}

variable "cluster_ca_certificate" {
  type = string
}