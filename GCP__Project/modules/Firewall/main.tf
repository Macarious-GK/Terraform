resource "google_compute_network_firewall_policy_with_rules" "primary" {
  name = "mac-terraform-fw-policy"
  description = "Mac-Terraform test"

  dynamic "rule" {
    for_each = var.rules
    content {
      description = rule.value.description
        priority    = rule.value.priority
        enable_logging = rule.value.enable_logging
        action         = rule.value.action
        direction      = rule.value.direction
        match {
          src_ip_ranges = rule.value.match.src_ip_ranges
          dest_ip_ranges = rule.value.match.dest_ip_ranges

          layer4_config {
            ip_protocol = rule.value.match.layer4_config.ip_protocol
            ports       = rule.value.match.layer4_config.ports
          }
        }
    }
    
  }

}