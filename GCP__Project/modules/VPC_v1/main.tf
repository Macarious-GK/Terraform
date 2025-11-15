# VPC Network
resource "google_compute_network" "General_vpc_network" {
  name = var.vpc.name
  project = var.vpc.project_id
  auto_create_subnetworks = var.vpc.auto_create_subnetworks
}


# Subnetwork

resource "google_compute_subnetwork" "general_vpc_subnetwork" {
    for_each      = var.vpc.subnets
    name          = each.value.name
    network       = google_compute_network.General_vpc_network.id
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
