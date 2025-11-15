output "vpc_id" {
  description = "vpc_id"
  value = google_compute_network.General_vpc_network.id
}

output "subnets_ids" {
  value = [for subnet in google_compute_subnetwork.general_vpc_subnetwork : subnet.id]
}