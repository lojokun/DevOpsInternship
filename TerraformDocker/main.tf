terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.13.0"
    }
  }
}

provider "docker" {
  host = "npipe:////.//pipe//docker_engine"
}

resource "docker_image" "mongo" {
  name         = "simoneldavid/mongodb-for-login-app:latest"
  keep_locally = false
}

resource "docker_container" "mongo" {
  image = docker_image.mongo.latest
  name  = "mongodb"
  ports {
    internal = 27017
    external = 27017
  }
}

resource "docker_image" "webapp" {
  name = "simoneldavid/login_app:latest"
}

resource "docker_container" "webapp" {
  image = docker_image.webapp.latest
  name  = "webapp"
  ports {
    internal = 5000
    external = 5000
  }
}
