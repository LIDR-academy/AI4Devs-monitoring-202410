# Variables para la configuración de Datadog

variable "datadog_api_key" {
  description = "API Key para Datadog"
  type        = string
  sensitive   = true
}

variable "datadog_app_key" {
  description = "App Key para Datadog"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Entorno de despliegue (production, staging, development)"
  type        = string
  default     = "production"
}

variable "team" {
  description = "Equipo responsable"
  type        = string
  default     = "sre"
}

variable "application" {
  description = "Nombre de la aplicación"
  type        = string
  default     = "lti-project"
}

variable "notification_email" {
  description = "Email para notificaciones de alertas"
  type        = string
  default     = "jlsanchez.oc@gmail.com"
}

variable "notification_slack" {
  description = "Canal de Slack para notificaciones de alertas"
  type        = string
  default     = "sre-alerts"
}

variable "datadog_site" {
  description = "Site de Datadog (datadoghq.com, datadoghq.eu, etc.)"
  type        = string
  default     = "datadoghq.com"
}

variable "datadog_api_url" {
  description = "URL de la API de Datadog"
  type        = string
  default     = "https://api.datadoghq.com"
}
