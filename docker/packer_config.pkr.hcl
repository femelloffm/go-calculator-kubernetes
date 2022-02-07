packer {
  required_plugins {
    docker = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/docker"
    }
  }
}

variable "docker_username" {
  type    = string
  default = ""
}

variable "docker_password" {
  type    = string
  default = ""
}

variable "app_path" {
  type    = string
  default = "/go/src/calculator-app"
}

source "docker" "go" {
  image  = "golang:1.17"
  commit = true
  changes = [
    "WORKDIR ${var.app_path}",
    "ENTRYPOINT [\"go\", \"run\", \"calculator_service.go\"]",
    "EXPOSE 8080"
  ]
}

build {
  sources = ["source.docker.go"]

  provisioner "file" {
    destination = "${var.app_path}"
    source      = "./docker/calculator-app"
  }

  post-processors {
    post-processor "docker-tag" {
      repository = "femelloffm/go-calculator"
      tags       = ["1.0"]
    }

    post-processor "docker-push" {
      login          = true
      login_username = var.docker_username
      login_password = var.docker_password
    }
  }
}