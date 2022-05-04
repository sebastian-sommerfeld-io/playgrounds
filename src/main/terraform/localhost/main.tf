terraform {
  required_version = ">= 1.1.9"

  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "~> 2.13.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "website" {
  name = "sommerfeldio/website:latest"
  keep_locally = false
}

resource "docker_container" "website-1" {
  image = docker_image.website.name
  name = "tf-website-1"
  ports {
    internal = 80
    external = 7080
  }
}

resource "docker_image" "docs-website" {
  name = "sommerfeldio/docs-website:latest"
  keep_locally = false
}

resource "docker_container" "website-2" {
  image = docker_image.docs-website.name
  name = "tf-website-2"
  ports {
    internal = 80
    external = 7081
  }
}

resource "docker_image" "apache" {
  name = "httpd:2.4"
  keep_locally = false
}

resource "docker_container" "apache-1" {
  image = docker_image.apache.name
  name = "tf-apache-1"
  ports {
    internal = 80
    external = 7000
  }
}
