# output "vpc_0_id" {
#   value = google_compute_network.mac_vpc_network_auto.id
# }
# output "vpc_1_id" {
#   value = google_compute_network.mac_vpc_network_custom_static_subnet.id
# }
# output "vpc_2_id" {
#   value = google_compute_network.mac_vpc_network_custom_dynamic_subnet.id
# }


output "vm_ex_ip" {
  value = module.VM_1.vm_ex_ip
}

