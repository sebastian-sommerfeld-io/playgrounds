resource "digitalocean_loadbalancer" "playground-lb" {
  name   = "playground-lb"
  region = "fra1"

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = 80
    target_protocol = "http"
  }

  healthcheck {
    port     = 22
    protocol = "tcp"
  }

  droplet_ids = [digitalocean_droplet.playground-www-1.id, digitalocean_droplet.playground-www-2.id]
}