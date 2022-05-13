#resource "digitalocean_certificate" "cert" {
#  name = "playground-cert" # when cert expires, do I need a new name here?
#  type = "lets_encrypt"
#  #domains = [digitalocean_domain.cloud.name]
#  domains = [var.domain_fqdn]
#
#  #  lifecycle {
#  #    create_before_destroy = true
#  #  }
#}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = "sebastian@sommerfeld.io"
}

resource "acme_certificate" "certificate" {
  account_key_pem           = acme_registration.reg.account_key_pem
  common_name               = var.domain_fqdn
  subject_alternative_names = [var.domain_fqdn]

  dns_challenge {
    provider = "digitalocean"
    config = {
      DO_AUTH_TOKEN = var.do_token
    }
  }
}
