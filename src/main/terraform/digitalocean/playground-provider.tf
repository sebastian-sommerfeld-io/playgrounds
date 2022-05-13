terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }

    acme = {
      source  = "vancluever/acme"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {}

variable "pvt_key" {
  type    = string
  default = "/root/.ssh/digitalocean_droplets.key" # path inside the docker container that runs terraform cli
}

variable "domain_fqdn" {
  type    = string
  default = "playground.cloud.sommerfeld.io"
}

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "terraform" {
  name = "kobol-digitalocean-droplets"
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
  #server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}
