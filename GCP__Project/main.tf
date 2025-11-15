module "VPC_v2" {
    source = "./modules/VPC_v2"
    vpc = {
       vpc_1 = {
            name                    = "general-vpc-network"
            auto_create_subnetworks = false
            subnets = {
                subnet_1 = {
                    name          = "general-subnetwork-1"
                    region        = "us-central1"
                    ip_cidr_range = "10.0.0.0/24"   
                },
                subnet_2 = {
                    name          = "general-subnetwork-2"
                    region        = "us-east1"
                    ip_cidr_range = "10.0.1.0/24"
                }
            } 
        },
    }
}


module "VM_1" {
    source = "./modules/VM_v1"
    vm = {
        name         = "macarious-first-gcp-terraform-instance"
        machine_type = "e2-micro"
        zone         = "us-central1-a"
        network_interface = {
            network    = module.VPC_v2.vpc_id[0]
            subnetwork = module.VPC_v2.subnets_ids[0]
        }
    }
}


module "firewall" {
    source = "./modules/Firewall"
    rules = [
        {
            name        = "allow-ssh-ingress"
            description = "Allow SSH ingress traffic"
            action      = "allow"
            enable_logging = true
            direction   = "INGRESS"
            priority    = 1
            match = {
                src_ip_ranges = ["0.0.0.0/0"]
                dest_ip_ranges = ["0.0.0.0/0"]
                layer4_config = {
                    ip_protocol = "tcp"
                    ports       = ["22"]
                }
            }
        },
        {
            name        = "deny-ping-egress"
            description = "Deny ping egress traffic"
            action      = "deny"
            enable_logging = true
            direction   = "EGRESS"
            priority    = 2
            match = {
                src_ip_ranges = ["0.0.0.0/0"]
                dest_ip_ranges = ["0.0.0.0/0"]
                layer4_config = {
                    ip_protocol = "icmp"
                }
            }
        },


    ]
}


# resource "null_resource" "check_vm_ip" {
#     provisioner "remote-exec" {
#         inline = [
#             "ip -c addr"
#         ]
#     }
#     connection {
#         type        = "ssh"
#         host        = module.VM_1.vm_instance_ip
#         user        = "ubuntu"
#         private_key = file("key/path")
#     }
  
# }








# module "VPC" {
#     source = "./modules/VPC_v1"
#     vpc = {
#         name                    = "general-vpc-network"
#         project_id              = "sage-buttress-478111"
#         auto_create_subnetworks = false
#         subnets = {
#             subnet-1 = {
#                 name          = "general-subnetwork-1"
#                 region        = "us-central1"
#                 ip_cidr_range = "10.0.0.0/24"   
#             }
#             subnet-2 = {
#                 name          = "general-subnetwork-2"
#                 region        = "us-east1"
#                 ip_cidr_range = "10.0.1.0/24"
#             }
#         }  
#     }
# }