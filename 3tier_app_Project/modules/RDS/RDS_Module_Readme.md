# AWS RDS
- This module is from `hashicorp/terraform-provider-aws` Provider

## Steps

When we want to launch rds instance, we need this:
- Subnets to deploy our instance in. (subnets already need vpc)
- Security Groups for accessing the instance
- Parameters for the db engine (act as config for the engine )
- DB_instance 

## Make sure 
- Subnets (public/private)
- Availability-Reliability (MultiAZ, backup, autoscaling through "max_allocated_storage")
- public access or not
- deletion_protection on/off
- db (name, password, username)
- performance (engine type, instance type)
- Security (enable Encryption)
