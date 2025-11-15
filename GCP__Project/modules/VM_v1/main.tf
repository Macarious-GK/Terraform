resource "google_compute_instance" "vm_instance" {
  name         = var.vm.name
  machine_type = var.vm.machine_type
  zone         = var.vm.zone
  boot_disk {
    initialize_params {
      image = "ubuntu-2204-jammy-v20251111"
      
    }
  }

  network_interface {
    network = var.vm.network_interface.network
    subnetwork = var.vm.network_interface.subnetwork
    access_config {
    }
  }
  
  lifecycle {
    prevent_destroy = true
  }
}


# resource "google_compute_instance" "vm_instance" {
#   name         = "macarious-first-gcp-terraform-instance"
#   machine_type = "e2-micro"
#   zone         = "us-central1-a"
#   boot_disk {
#     initialize_params {
#       image = "debian-cloud/debian-11"
#     }
#   }

#   network_interface {
#     # A default network is created for all GCP projects
#     network = "default"
#     access_config {
#     }
#   }
# }
