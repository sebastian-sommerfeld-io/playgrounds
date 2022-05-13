resource "digitalocean_loadbalancer" "playground-lb" {
  name   = "playground-lb"
  region = "fra1"

  forwarding_rule {
    entry_port      = 443
    entry_protocol  = "https"
    target_port     = 80
    target_protocol = "http"
    #    certificate_id = acme_certificate.certificate.id
    certificate_name = acme_certificate.certificate.common_name
    #    certificate_name = digitalocean_certificate.cert.name
  }

  healthcheck {
    port     = 22
    protocol = "tcp"
  }

  droplet_ids = [digitalocean_droplet.playground-www-1.id, digitalocean_droplet.playground-www-2.id]
}
