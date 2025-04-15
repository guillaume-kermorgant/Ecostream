terraform {
	
  backend "local" {
    path = "terraform.tfstate"
  }

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {
  registry_auth {
    address  = "registry.gitlab.com"
    username = var.gitlab_username
    password = var.gitlab_token
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

variable "ecostream_database_host" {
  type        = string
  description = "EcoStream database host"
  default     = "localhost"
}

variable "ecostream_database_port" {
  type        = number
  description = "EcoStream database port"
  default     = 5432
}

variable "ecostream_database_user" {
  type        = string
  description = "EcoStream database user"
  default     = "ecostream"
}

variable "ecostream_database_password" {
  type        = string
  description = "EcoStream database password"
  default     = "ecostream-password"
}

resource "docker_image" "ecostream_manager" {
  name         = "registry.gitlab.com/gkermo/ecostream-manager:latest-amd64"
  keep_locally = false
}

resource "docker_image" "ecostream_visualizer" {
  name         = "registry.gitlab.com/gkermo/ecostream-visualizer:latest-amd64"
  keep_locally = false
}

resource "docker_image" "ecostream_database" {
  name         = "registry.gitlab.com/gkermo/ecostream-database:latest-amd64"
  keep_locally = false
}

resource "docker_container" "ecostream_database_container" {
  image = docker_image.ecostream_database.name
  name  = "ecostream_database"

  ports {
    internal = 5432
    external = var.ecostream_database_port
  }

  env = [
    "POSTGRES_USER=${var.ecostream_database_user}",
    "POSTGRES_PASSWORD=${var.ecostream_database_password}"
  ]

  restart = "no"
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
    "ECOSTREAM_MANAGER_PASSWORD=${var.ecostream_manager_password}",
    "ECOSTREAM_DB_HOST=${var.ecostream_database_host}",
    "ECOSTREAM_DB_PORT=${var.ecostream_database_port}",
    "ECOSTREAM_DB_USER=${var.ecostream_database_user}",
    "ECOSTREAM_DB_PASSWORD=${var.ecostream_database_password}"
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

