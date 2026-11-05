variable "subscription_id" {
  description = "Azure subscription that hosts the project"
  type        = string
}

variable "owner" {
  description = "Value of the owner tag"
  type        = string
  default     = "raulvaldes-cetys"
}

variable "container_registry_name" {
  description = "Name of the shared container registry created by baja-valle-service/infra"
  type        = string
}

variable "image_tag" {
  description = "Image tag for the first deployment; later deployments update the image from CI"
  type        = string
}

variable "github_repository" {
  description = "Repository allowed to deploy with OIDC (owner/name)"
  type        = string
  default     = "raulvaldes-cetys/baja-valle-web"
}
