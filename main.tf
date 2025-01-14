terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

variable "gitlab_username" {
  type        = string
  description = "GitLab username"
}
variable "gitlab_token" {
  type        = string
  description = "GitLab auth token"
}

variable "ecostream_manager_external_port" {
  type        = number
  description = "EcoStream manager port"
  default     = 9000
}

variable "ecostream_manager_username" {
  type        = string
  description = "EcoStream manager username"
  default     = "manager"
}

variable "ecostream_manager_password" {
  type        = string
  description = "EcoStream manager password"
  default     = "manager-password"
}

provider "docker" {
  registry_auth {
    address  = "registry.gitlab.com"
    username = var.gitlab_username
    password = var.gitlab_token
  }
}

resource "docker_image" "ecostream_manager" {
  name         = "registry.gitlab.com/gkermo/ecostream-manager:latest-amd64"
  keep_locally = false
}

resource "docker_image" "ecostream_visualizer" {
  name         = "registry.gitlab.com/gkermo/ecostream-visualizer:latest-amd64"
  keep_locally = false
}

resource "docker_container" "ecostream_manager_container" {
  image = docker_image.ecostream_manager.name
  name  = "ecostream_manager"

  ports {
    internal = 9000
    external = var.ecostream_manager_external_port
  }

  env = [
    "ECOSTREAM_MANAGER_USERNAME=${var.ecostream_manager_username}",
    "ECOSTREAM_MANAGER_PASSWORD=${var.ecostream_manager_password}"
  ]

  restart = "no"
}

resource "docker_container" "ecostream_visualizer_container" {
  image = docker_image.ecostream_visualizer.name
  name  = "ecostream_visualizer"

  ports {
    internal = 80
    external = 3000
  }

  env = [
    "REACT_APP_ECOSTREAM_MANAGER_USERNAME=${var.ecostream_manager_username}",
    "REACT_APP_ECOSTREAM_MANAGER_PASSWORD=${var.ecostream_manager_password}",
    "REACT_APP_ECOSTREAM_MANAGER_URL=http://localhost:${var.ecostream_manager_external_port}"
  ]

  restart = "no"
}