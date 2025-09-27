# Terraform
- IaC tool for automating resource provisioning across multiple providers.
- It used HashiCorp Configuration Language (HCL).
## Table of Contents

- [Introduction](#introduction)
    - [HCL Basics Structure](#hcl-basics-structure)
    - [Workflow](#workflow)
- [Terraform Core](#terraform-core)
    - [Terraform Providers](#terraform-providers)
        - [Provider Requirements](#provider-requirements)
        - [Provider Authentication](#provider-authentication)
        - [Provider Alias](#provider-alias)
        - [Provider Versions](#provider-versions)
        - [Updating Providers](#updating-providers)
    - [Resource](#resource)
        - [Attributes & Dependencies](#attributes--dependencies)
        - [LifeCycle Rules](#lifecycle-rules)
        - [Datasource](#datasource)
        - [Meta Arguments, count & for-each](#meta-arguments-count--for-each)
    - [Variables](#variables)
    - [Output](#output)
    - [Terraform State](#terraform-state)
        - [Import Command](#import-command)
        - [State Management Commands](#state-management-commands)
- [Terraform CLI](#terraform-cli)
    - [Workspace](#workspace)
        - [Misconception](#misconception)
        - [WS Notes](#ws-notes)
        - [Example Use](#example-use)
    - [Debugging & Logs](#debugging--logs)
    - [Terraform Provisioners](#terraform-provisioners)
        - [Remote Execution](#remote-execution)
        - [Local Execution](#local-execution)
        - [Terraform Taint](#terraform-taint)
- [Logic & Config](#logic--config)
    - [Terraform Modules](#terraform-modules)
    - [Functions](#functions)
    - [Terraform File Handling Functions](#terraform-file-handling-functions)
    - [Locals & Dynamic Blocks](#locals--dynamic-blocks)
        - [Locals](#locals)
        - [Dynamic](#dynamic)
- [Commands](#commands)
- [Project (Create a Custom Provider)](#project-create-a-custom-provider)

## Introduction
### HCL Basics Structure
- Terraform config files end with `.tf` and are made up of blocks:
    - ***Block*** → Defines a piece of config (*provider, resource, variable, output*).
    - ***Labels*** → Identifiers (provider, resource_type, resource_name).
    - ***Arguments*** → Key-value pairs inside blocks (*String, Number, Boolean, List, Map, Expressions*).
```HCL
block_type "provider_resourceType" "label2" {
  String_argument = "value"
  Number_argument = 3
  Boolean_argument = true
  List_argument = ["us-east-1a", "us-east-1b"]
  Map_argument = {
    Environment = "Dev"
    Owner       = "TeamA"
    }
  Expressions_argument = aws_s3_bucket.mybucketname.id
}
```

### Workflow
- terraform init → Initialize provider plugins
- terraform plan → Preview changes
- terraform apply → Create/update infra
- terraform show → show the created state resources
- terraform output → print the outputs 
- terraform destroy → Tear down infra

## Terraform Core 
### Terraform Providers
- A provider is a plugin that allows Terraform to manage resources in a specific platform (AWS, Azure, GCP, etc.).
- Provider act as the bridge to your infra APIs.
- Providers can be:
    - (official): hashicorp/aws
    - (community): integrations/github 
    - (partner): datadog/datadog 
- We install the provider in `terraform init`
    - We specify the **source** & **version**
- ***`.terraform.lock.hcl`***: 
  - Records the exact version and checksums or required providers
  - Lock any update in versions to keep consistency until `terraform init -upgrade`

#### Provider Requirements
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.34"
    }
  }
  required_version = ">= 1.6.0, < 2.0.0"
}
```

#### Provider Authentication
1. Environment Variables
```bash
export AWS_ACCESS_KEY_ID="AKIA..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_SESSION_TOKEN="..."   # for temporary credentials
export AWS_DEFAULT_REGION="us-east-1"
```

2. Shared Credentials & Config Files
- Location: ~/.aws/credentials and ~/.aws/config
3. AWS CLI / SDK Defaults
- Terraform can use the same credentials that the AWS CLI or SDK is already using.
4. IAM Roles (Instance Metadata / STS)
If Terraform runs on an EC2, ECS, or EKS instance with an attached IAM Role, credentials are automatically retrieved.
No keys required — safer for production.

#### Provider Alias
- In Terraform, each provider block configures one instance of a provider.
- You can give a provider an `alias` to create ***multiple distinct configurations of the same provider type***.
- We use it, inside resources or modules to specify the desired provider.
```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}
module "app" {
  source   = "./app"
  providers = {
    aws = aws.west
  }
}
```
- First one is the default, the second is an aliased provider
- We can pass the alias provider to modules 
- Use cases:
    - Multi-region/Multi-account deployments

#### Provider Versions
- **MAJOR.MINOR.PATCH** *==* **5.34.0**
- *regular constraint*: anything newer that exists.
  - => 5.43 → allows `any newer version `
- *pessimistic constraint*: update minor/patch only.
  - ~> 5.34 → allows `>= 5.34.0 and < 5.35.0`.
  - ~> 5.0 → allows `>= 5.0.0 and < 6.0.0`.

#### Updating providers
```bash
terraform init -upgrade
terraform providers
```

---

### Resource
> ####  Attributes & Dependencies
- Each resource we define has a set of attributes.
- When we create a resource, we may pass a value of its attributes to another resource by **reference attribute**.
- We can specify the order of the resource creation by specifying witch resource depend on witch by `depends_on` attribute.
- Dependencies Types:
  - Implicit Dependency: Happens automatically when one resource references an attribute of another resource.
  - Explicit Dependency: you manually tell Terraform that one resource depends on another using the depends_on argument.

- recourse types:
  - Logical 
  - Local
  - Cloud 

```hcl
resource "local_file" "file1" {
  filename = "/root/mac1.txt"
  content  = "This is file1"
}

resource "local_file" "file2" {
  filename = "/root/mac2.txt"
  content  = "The filename of file1 is: ${local_file.file1.filename}"     # Reference
  depends_on = [local_file.file1]                                         # depends_on ensures ordering
}
```

> #### LifeCycle Rules
- When terraform update resources it destroy the old one and create a new one `immutable`
- Default behavior: delete the old and create the new
- We can change this behavior by using `LifeCycle Rules`
```hcl
resource "local_file" "file1" {
  filename = "/root/mac1.txt"
  content  = "This is file1"
  lifecycle {
    create_before_destroy = true
    prevent_destroy = true              # prevent the destroy when using (apply)
    ignore_changes = [                  # Ignore changes made to the content attribute
      content
    ] 
  }
}
```

> #### Datasource
- When we want to use data or content from a resource that is not controlled by terraform we can use datasources
- We define it as data (*same as resources*) then access its desired content 

```hcl 
data "local_file" "example" {
  filename = "/root/message.txt"
}

output "file_content" {
  value = data.local_file.example.content
}
```

> #### Meta Arguments, count & for-each
- When we want to create multiple recourses with the same config ex: 3 files. use ***count and for-each***
- `count` work with a stable index variables, like a list of resource:
  - to make it dynamic we can use function called `length`
  - Use **count.index** to access count order
  - *Bads*: order matter because it is list **changes may affect the whole resource created**
- `for-each` is used with map or a set, and it will produce a map of resources
- In order to use for-each we should work with **set or map** variable type
  - change it in variable using `type`
  - change it in main using `toset` function 

```hcl
# variables.tf
variable "filename" {
  type = set(string)
  default = [
    "root/dogs.txt",
    "root/cats.txt"
  ]
}
# main.tf when using count
resources "local_file" "pets" {
  filename = var.filename[count.index]
  count = length(var.filename)
}

# main.tf when using for-each
resources "local_file" "pets" {
  filename = each.value
  for_each = toset(var.filename)
}

```

---

### Variables
- Variables in Terraform are like placeholders. They allow you to parameterize configurations so you don’t hardcode values and makes your code reusable, flexible, and easier to manage.
- Variables Types:
  - String
  - Number
  - Boolean
  - List "list(string), list(number)"
  - Map "map(string), map(number)"
  - Set "set(string), set(number)"    -> No Duplicates
  - Objects
  - Tuples

- We have to declare the variables in the first place, this happened in `variables.tf` file and it optionally contain the default values.
- We use this variables in the main file by referencing using the `var` keyword followed by the `variable name`

```hcl
# Normal String
variable "ami"{
  description = "AMI of EC2 instance"
  type        = string
  default = "ami-f46dsf65sd4fdfsd"

  validation {
    condition     = contains(["ami-fsdfs", "ami-gfgdf"], var.ami)
    error_message = "Only ami-fsdfs ami-gfgdf are allowed."
  }
}

# List of Strings
variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# Map of Strings
variable "instance_types" {
  type = map(string)
  default = {
    dev  = "t2.micro"
    prod = "t3.large"
  }
}

# Object
variable "server_config" {
  type = object({
    name     = string
    cpu      = number
    memory   = number
    enabled  = bool
  })
  default = {
    name    = "web-server"
    cpu     = 2
    memory  = 4096
    enabled = true
  }
}

# Tuple 
variable "app_data" {
  type    = tuple([string, number, bool])
  default = ["frontend", 3, true]
}

resource "aws_instance" "example" {
  ami           = var.ami
  instance_type = var.instance_types["dev"]
  availability_zones = var.availability_zones[1]
  value1 = var.server_config.name
  value2 = var.app_data[0]

}
```
- Using Variables (When no default is set) ***in order***:
  1. Export the environment values like `export TF_VAR_filename="somevalue"`
  2. Use **variable definition files** `terraform.tfvars`then in the cli by `-var-file terraform.tfvars` 
  3. Use **variable definition files** `*.auto.tfvars` then in the cli by `-var-file *.auto.tfvars` 
  4. **Command line flags** `Highest Priority`: Provide the variables interactively in CLI by `-var` in `terraform apply`

--- 


### Output
- An output lets you display or export values from your Terraform project.
- Think of them like return values in a function.
- After we destroy resources, it output of our previous outputs state & changes it to null
```hcl
output "instance_PV_ip" {
  value       = aws_instance.web.private_ip
  description = "Private IP of the EC2 instance"
  sensitive   = true
}

output "instance_PUB_ip" {
  value       = aws_instance.web.public_ip
  description = "Public IP of the EC2 instance"
}
```
- **`Output flags`**
  - The ***-raw*** option only supports strings, numbers, and boolean values.
  - Use the ***-json*** option for output values that have complex types. 
- commands:
```bash
terraform output
terraform output -json
terraform output -raw outputVarName       
```

---

### Terraform State
- Its the single source of truth for terraform 
- When we use `terraform apply`, it creates terraform state file that contain the state of the file
- State file help resolve dependencies issus when deleted
- Useful for Tracking Metadata, collaboration (*Sharing the .tfstate file*) & Performance
- `State Locking`:
  - To prevent concurrent execution of terraform (Race Conditions)
- `Remote State Backends`:
  - Store the state file in a secure shared remote backend storage solution ex:`AWS S3` 
  - Store state-Locking in `DynamoDB table`

```hcl
terraform{
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "path/to/the/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"  # for state locking
    encrypt        = true
  }
}
```

#### Import command
- When we have resources out of terraform management and want it to be under it
- We use import command
- before we can import it, we should create a resource in our main config
```bash
terraform import aws_instance.webserver id
```
- Manipulate State by using `terraform state` command & sub commands `list, mv, pull, rm, show`

#### State Management commands
```bash
terraform state list                            # list resources in state
terraform state show <resource>                 # Show resource details of
terraform state rm <resource>                   # remove resource from state
terraform state mv <resource> <new-resource>    # move resources in state (rename)
terraform state pull / push                     # Downloads/Uploads state file from/to remote backend
terraform import aws_vpc.myvpc id               # Adds an existing AWS resource into your Terraform state
```

---

## Terraform CLI
### Workspace
- A workspace is a separate state file managed by Terraform within the same working directory/configuration.
- act as *namespaces for state files*
```bash
terraform workspace list
terraform workspace show
terraform workspace new prod
terraform workspace select dev
terraform workspace delete dev
```

#### Misconception
1. Workspaces are for multi-environment management
  - Quick experiments, Isolated testing
2. Workspaces share state
  - Each workspace has its own state
3. Terraform Cloud Workspaces = CLI Workspaces
  - concepts differ
4. Workspaces prevent resource name collisions
  - You must include terraform.workspace in resource naming to avoid conflicts.

#### WS Notes
- The purpose of workspaces (separate state, not separate configs).
- How to reference the current workspace in code (terraform.workspace).

#### Example use
```hcl
resource "aws_s3_bucket" "example" {
  bucket = "my-app-${terraform.workspace}-bucket"
  tags = {
    Environment = terraform.workspace
  }
}
#-----------------------------------------------------
variable "ami" {
  type = map(string)
  default = {
    "ProjectA" = "ami-0edab43b6fa892279"
    "ProjectB" = "ami-0c2f25c1f66a1ff4d"
  }
}
# Main.tf
resource "aws_instance" "project" {
  ami           = lookup(var.ami, terraform.workspace)
  instance_type = var.instance_type
  tags = {
    Name = terraform.workspace
  }
}
```

### Debugging & Logs
- To enable logs we should uses environment variables for logging
- We can also define path to a file for this logs

| Level   | What it shows                                           |
| ------- | ------------------------------------------------------- |
| `ERROR` | Only errors                                             |
| `WARN`  | Errors + warnings                                       |
| `INFO`  | Normal operational logs                                 |
| `DEBUG` | Detailed internal logs                                  |
| `TRACE` | Very detailed, step-by-step execution (developer-level) |

```bash
export TF_LOG=TRACE
export TF_LOG_PATH=Path/to/file
```

### Terraform Provisioners
- a provisioner is a way to run scripts or commands on a resource after it is created or destroyed.
- They are intended as a last resort when native resource configurations are not available.
  - With ec2 use `user_data` instead of `provisioner`
#### Remote Execution
```hcl
resource "aws_instance" "webserver" {
  ami           = "ami-0edab43b6fa892279"
  instance_type = "t2.micro"
  
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install nginx -y",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx",
    ]
  }
  
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("/root/.ssh/web")
  }
  
  key_name               = aws_key_pair.web.id
  vpc_security_group_ids = [aws_security_group.ssh-access.id]
}

resource "aws_key_pair" "web" {
  # << code hidden >>
}
```

#### Local Execution

```hcl
resource "aws_instance" "webserver" {
  ami           = "ami-0edad43b6fa892279"
  instance_type = "t2.micro"

  provisioner "local-exec" {
    command = "echo ${aws_instance.webserver.public_ip} >> /tmp/ips.txt"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo Instance ${aws_instance.webserver.public_ip} Destroyed! > /tmp/instance_state.txt"
  }
}
```

#### Terraform Taint
- Terraform marks a resource as tainted when it encounters errors during creation, such as a failed provisioner command. 
- This command is deprecated. Instead, add the -replace option to your terraform apply command.

```bash
terraform apply -replace="aws_instance.example[0]"
```

## Logic & Config
### Terraform Modules
- A module in Terraform is just a container for Terraform configuration files (.tf files).
- Modules let you group resources together and reuse them across projects.
- Its like functions in programming: write once, reuse many times.
- Types of Modules:
  - Root Module
  - Local Module 
  - Remote Module

```hcl
# Prepare the desired resources in the path of /modules/payroll-app then reuse it using module
module "us_payroll" {
  source     = "../modules/payroll-app"
  app_region = "us-east-1"
  ami        = "ami-24e140119877avm"
}
```

### Functions
```hcl
out = startswith("prod-app-server", "prod")   # return true
out = endswith("mybucket-prod", "prd")        # return false
out = coalesce(var.name, "default name")      # if var.name is null it return default_name
out = concat(["a", "b"], ["c", "d"])          # return ["a", "b", "c", "d"] 
out = flatten([["a", "b"], ["c", "d"]])       # return ["a", "b", "c", "d"]
out = join(".", ["a", "b", "c"])              # return "a.b.c"
```
Functions (dynamic)
  1   length()
  1   merge()
  1   element()
  1   contains()
  1   file()
  1   filebase64()
  1   templatefile()
  1   for expressions
  1   try()
  1   startswith(string, prefix)          # Checks if a string starts with a given suffix.
  1   endswith(string, suffix)            # Checks if a string ends with a given suffix.
  1   coalesce(val1, val2, ...)           # Returns the first non-nul argument.
  1   concat(list1, list2, ...)           # joins multiple lists into 1 list (no flatten for nested lists)
  1   flatten(list)                       # flatten the list of nested lists to one list 
  1   join(separator, list_of_strings)    # takes a list of strings and combines them into a single string
  1   lookup(map, key, default)           # using key gets a value from a map, with a default fallback if the key doesn’t exist
  1   terraform.workspace                 # the value of the workspace name
  _   slice()
  _   format()
  _   formatlist()
  _   tolist()
  _   tomap()
  _   tostring()

### Terraform File Handling Functions
> #### `file(path)`
- Read a file and returns its content in string
- Useful for shell scripts, configs, and static content.

> #### `filebase64(path)`
- Reads a file and returns its base64-encoded string.
- Sometimes Required by providers (AWS)

> #### `templatefile(path, vars)`

- Used when you need dynamic values.
```hcl
user_data = templatefile("userdata.tpl", {
  app_name   = "myapp"
  server_env = "production"
})
```

> #### `fileexists(path)`
- Returns true if a file exists.

> #### `fileset(path, pattern)`
- Returns a set of file names that match a glob pattern.
```hcl
locals {
  configs = fileset("${path.module}/configs", "*.json")
}
```

#### Combining Functions
- Base64-encode a templated file
```hcl
user_data_base64 = base64encode(templatefile("userdata.tpl", {
  env = var.environment
}))
```

- Conditional file loading
```hcl
user_data = fileexists("${path.module}/userdata.sh") ? file("${path.module}/userdata.sh") : ""
```

### Locals & Dynamic Blocks
#### Locals
- internal constants/expressions for DRY, readability, consistency and **Centralize logic**.
- Use them for naming conventions, computed values, reusable logic, and tagging.
```hcl
locals {
  region         = "us-east-1"
  project_name   = "my-app"
  instance_count = 3
}

provider "aws" {
  region = local.region
}
```

#### Dynamic
- Use a dynamic block when you have a list or map of similar nested items but you don’t know the exact number ahead of time.
- Terraform will loop over the list/map and create a corresponding nested block for each item automatically.
- Example: "SecurityGroup rules"

```hcl
variable "ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

resource "aws_security_group" "example" {
  name = "demo"

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}
```


## Commands
```bash
terraform init
terraform init -upgrade

terraform plan                # preview changes.
terraform plan -out=plan.out

terraform apply               # Apply changes.  
terraform apply plan.out
terraform apply -refresh=false
terraform apply -auto-approve
terraform apply -var-file=terraform.prod.tfvars
terraform apply -replace=<resource>
terraform apply -parallelism=10     # the default is 10 and respect the dependency tree

terraform destroy 
terraform destroy -target=<resource>
terraform destroy -auto-approve

terraform provider            # List all providers in this project
terraform provider mirror path/to/new/location           # copy providers to another place

terraform output
terraform output -json
terraform output -raw outputVarName 

terraform state list                            # list resources in state
terraform state show <resource>                 # Show resource details of
terraform state rm <resource>                   # remove resource from state
terraform state mv <resource> <new-resource>    # move resources in state (rename)
terraform state pull / push                     # Downloads/Uploads state file from/to remote backend
terraform import aws_vpc.myvpc id               # Adds an existing AWS resource into your Terraform state

terraform workspace list
terraform workspace show
terraform workspace new prod
terraform workspace select dev
terraform workspace delete dev

terraform fmt                 # formate the configuration in better formate 
terraform fmt -recursive

terraform refresh             # Updates Terraform’s state file to reflect the real-world infra
terraform get 
terraform console 
terraform graph
terraform taint <resource>
terraform import <resource> <id>
terraform validate            # Validate the current configuration
```

## Terraform Cloud
### Sentinel Policy 
- Sentinel = HashiCorp’s policy-as-code framework.
- Works with Terraform Enterprise only
- Lets you define rules and guardrails for Terraform runs
- Evaluates plans, states, configs via imports (tfplan, tfstate, tfconfig).

#### Sentinel Policy Levels
1. Advisory → Policy runs, logs violations, but doesn’t block execution.
2. Soft Mandatory → Policy blocks by default, but can be overridden by an admin.
3. Hard Mandatory → Policy blocks and cannot be overridden.

#### Example:
- restrict instance types
```hcl
import "tfplan"

main = rule {
  all tfplan.resource_changes as _, rc {
    rc.type != "aws_instance" or
    rc.change.after.instance_type in ["t2.micro", "t3.micro"]
  }
}
```


<!-- ## Terraform Execution
## Project (Create a Custom Provider) -->
