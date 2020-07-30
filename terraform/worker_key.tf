resource "tls_private_key" "worker" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

output "worker_key" {
  value = tls_private_key.worker.private_key_pem
}

output "worker_key_pub" {
  value = tls_private_key.worker.public_key_pem
}
