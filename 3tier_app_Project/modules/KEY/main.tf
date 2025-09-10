resource "tls_private_key" "my_key" {
  algorithm = var.key_algorithm
  rsa_bits  = 4096
}


resource "aws_key_pair" "General_Key_Pair" {
  key_name   = var.key_name
  public_key = tls_private_key.my_key.public_key_openssh
}

resource "local_file" "private_key" {
  filename        = "${path.module}/mykeys/${var.key_name}_private.pem"
  content         = tls_private_key.my_key.private_key_pem
  file_permission = "0600"
}