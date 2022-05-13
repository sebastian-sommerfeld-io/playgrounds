#resource "digitalocean_domain" "cloud" {
#  name = "cloud.sommerfeld.io"
#  ip_address = digitalocean_loadbalancer.playground-lb.ip
#}
#
#resource "digitalocean_record" "CNAME-playground" {
#  domain = digitalocean_domain.cloud.name
#  type = "CNAME"
#  name = "playground"
#  value = "@"

resource "digitalocean_domain" "cloud" {
  name       = var.domain_fqdn
  ip_address = digitalocean_loadbalancer.playground-lb.ip
}
