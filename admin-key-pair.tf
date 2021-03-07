resource "tls_private_key" "tfkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private-key" {
  content  = tls_private_key.tfkey.private_key_pem
  filename = "tfkey.pem"
}

resource "aws_key_pair" "test" {
  key_name   = "tfkey"
  public_key = tls_private_key.tfkey.public_key_openssh
  depends_on = [tls_private_key.tfkey]
}