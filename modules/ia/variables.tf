variable "cluster_endpoint" {}
variable "access_token" {}
variable "cluster_ca_certificate" {}
variable "qdrant_api_key" {
  description = "La clave secreta para proteger la base de datos Qdrant"
  type        = string
  sensitive   = true 
}