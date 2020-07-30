variable "web_domain" {}

resource "tls_private_key" "tls_key" {
  algorithm = "ECDSA"
}

resource "tls_self_signed_cert" "web_tls" {
  key_algorithm         = tls_private_key.tls_key.algorithm
  private_key_pem       = tls_private_key.tls_key.private_key_pem
  validity_period_hours = 8760

  # Generate a new certificate if Terraform is run within 24
  # hours of the certificate's expiration time.
  early_renewal_hours = 24

  # Reasonable set of uses for a server SSL certificate.
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names = [var.web_domain]

  subject {
    common_name = var.web_domain
  }
}

output "web_tls_cert" {
  value = tls_self_signed_cert.web_tls.cert_pem
}

output "web_tls_key" {
  value = tls_private_key.tls_key.private_key_pem
}
