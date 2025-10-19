provider "kubernetes" {
  host = "https://192.168.56.10:6443"

  client_certificate     = file("${path.cwd}/creds/client-cert.pem")
  client_key             = file("${path.cwd}/creds/client-key.pem")
  cluster_ca_certificate = file("${path.cwd}/creds/cluster-ca-cert.pem")
}