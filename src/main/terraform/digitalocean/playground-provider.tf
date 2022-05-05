terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {}

variable "pvt_key" {
  type = string
  default = "/root/.ssh/digitalocean_droplets.key" # path inside the docker container that runs terraform cli
}

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "terraform" {
  name = "kobol-digitalocean-droplets"
}
