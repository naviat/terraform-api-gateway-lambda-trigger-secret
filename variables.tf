variable "secretID" {
  description = "Secret ID for each environment (dev or prod)"
  type        = string
}

variable "env" {
  description = "Deployment environment (dev or prod)"
  type        = string
  default     = "dev"
}
