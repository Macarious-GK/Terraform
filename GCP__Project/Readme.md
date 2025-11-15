# Project Description

## Stage 1: VPC
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
## To Do List
- Use For for_each count ✅
- Use Lookup, Contain, flatten, merge -> maps, concat -> lists ✅
- Use Complex Data Type ✅

- Use Dynamic ✅ Locals ✅

- Use 4 Validation 1✅
- Use Contain ✅
- Use Modules ✅
- Use Lifecycle ✅
- Use provisioners ✅
- Use terraform_remote_state ✅
- Use Try, (condition ? T : F) ✅
- Use Dynamic Tagging ✅

- Use data sources
- Blue Green    
- Use dependencies
- Use state refactoring







# GCP
## Identity and Access Management
### Authentication 
- Principle (User)
    - google account / google group
    - service account

### Authorization
- Use IAM Roles **(Set of permissions)**
- we grant a principle permissions by assigning to IAM Role
- Type of roles:
    - Basic
    - predefined
    - custom
- IAM Policy:

