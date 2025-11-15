# VPC Network
resource "google_compute_network" "General_vpc_network" {
  for_each = var.vpc
  name = each.value.name
  auto_create_subnetworks = each.value.auto_create_subnetworks
}


locals  {
  subnets = flatten([for vpckey, vpcvalues in var.vpc : [for subnetname, subnetdata in vpcvalues.subnets : {
    name = subnetdata.name
    region = subnetdata.region
    network = vpckey
    ip_cidr_range = subnetdata.ip_cidr_range
    }]])
 
  subnet_map = {for subnet in local.subnets : "${subnet.network}-${subnet.name}" => subnet}
}

resource "google_compute_subnetwork" "general_vpc_subnetwork" {
    for_each = local.subnet_map
    name          = each.value.name
    network       = google_compute_network.General_vpc_network[each.value.network].id
    region        = each.value.region
    ip_cidr_range = each.value.ip_cidr_range
}















# # Firewall Rules

# resource "google_compute_network_firewall_policy" "basic_network_firewall_policy" {
#   provider    = google-beta
#   name        = "fw-policy"
#   description = "Sample global network firewall policy"
#   project     = "my-project-name"
# }

# resource "google_compute_network_firewall_policy_rule" "primary" {
#   provider        = google-beta
#   action          = "allow"
#   description     = "This is a simple rule description"
#   direction       = "INGRESS"
#   disabled        = false
#   enable_logging  = true
#   firewall_policy = google_compute_network_firewall_policy.basic_network_firewall_policy.name
#   priority        = 1000
#   rule_name       = "test-rule"

#   match {
#     src_ip_ranges     = ["11.100.0.1/32"]
#     src_network_scope = "VPC_NETWORKS"
#     src_networks      = [google_compute_network.network.id]

#     layer4_configs {
#       ip_protocol = "all"
#     }
#   }
# }
