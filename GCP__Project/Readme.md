# Project Description

- Create a Custom VPC
    - Define a VPC network in custom mode (not auto-mode) to control IP ranges and network structure.

- Create Multiple Subnets
    - Create at least three subnets: public (web), private (app), and private (database) to practice subnet isolation and CIDR planning.

- Configure Firewall Rules
    - Set up rules to allow necessary traffic (web → app → database) and restrict all other traffic, learning stateful firewalls and priority rules.

- Configure Cloud NAT
    - Enable NAT for private subnets so instances without public IPs can access the internet.

- Define Routes
    - Create or verify routes to direct traffic inside the VPC and to the internet, understanding default and custom routing.