resource "digitalocean_certificate" "cert" {
  name = "playground-cert" # when cert expires, do I need a new name here?
  type = "lets_encrypt"
  #domains = [digitalocean_domain.cloud.name]
  domains = [var.domain_fqdn]

  lifecycle {
    create_before_destroy = true
  }
}

resource "digitalocean_loadbalancer" "playground-lb" {
  name   = "playground-lb"
  region = "fra1"

  forwarding_rule {
    entry_port       = 443
    entry_protocol   = "https"
    target_port      = 80
    target_protocol  = "http"
    certificate_name = digitalocean_certificate.cert.name
  }

  healthcheck {
    port     = 22
    protocol = "tcp"
  }

  droplet_ids = [digitalocean_droplet.playground-www-1.id, digitalocean_droplet.playground-www-2.id]
}
