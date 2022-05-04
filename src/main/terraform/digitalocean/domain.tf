resource "digitalocean_domain" "playground" {
  name = "playground-digitalocean.test.sommerfeld.io"
  ip_address = digitalocean_loadbalancer.www-lb.ip
}
