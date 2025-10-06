resource "local_file" "name" {
  content  = var.file_content
  filename = "${path.module}/hello.txt"
}

