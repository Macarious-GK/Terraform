terraform {

  backend "gcs" {
    bucket = "macarious-tf-state"
    prefix = "terraform/state"
  }
}
