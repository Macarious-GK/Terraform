resource "local_file" "name" {
  content  = "Hello, World!"
  filename = "${path.module}/hello.txt"
}

