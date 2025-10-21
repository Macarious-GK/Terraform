# Terraform
- It's Hashicorp Infra as code tool.
- Terraform manages resources on cloud and  services through their (APIs).
- IaC tool for automating resource provisioning across multiple providers.
- It used HashiCorp Configuration Language (HCL).
- Terraform is logically split into two main parts:
    1. `Terraform Core`: This is the Terraform binary that communicates with plugins to manage infrastructure resources.
    2. `Terraform Plugins`: executable binaries written in ***Go*** that communicate with Terraform Core over an ***RPC interface.***

<div style="text-align: center;">
<img src="./terraform-custom-provider-1600x350.webp" alt="Jenkins" width="1500" height="300" style="border-radius: 15px;">
</div>

### Infrastructure Lifecycle ***`Day 0 / Day 1+`***:
- `Day 0` : code provisions and configures your initial infra.
- `Day 1+` : refers to OS and app config you apply after you’ve initially built your infra.

### What Terraform Do
- `Refresh`: reconcile what terraform thinks the real world looks like
- `plan`: plan for design config
- `apply / destroy`: create/destroy the actual planned infra 

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
- [Exam List missingparts](#exam-list-missingparts)

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

5. **CLI flags** `Priority 1`: Provide the variables interactively in CLI by `-var`
4. **CLI flags** `Priority 2`: Provide the variables interactively in CLI by `-var-file`
3. Use **.auto.tfvars files** `*Priority 2` then in the cli by ` *.auto.tfvars` 
2. Use **terraform.tfvars files** `Priority 3`then in the cli by ` terraform.tfvars` 
1. Export the environment values like `export TF_VAR_filename="somevalue"`

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

output "<LABEL>" {
  value       = <EXPRESSION>
  description = "<STRING>"
  sensitive   = <true|false>
  ephemeral   = <true|false>
  depends_on  = [<REFERENCE>]

  precondition {
    condition     = <EXPRESSION>
    error_message = "<STRING>"
  }
}

```
- we can use the `ephemeral` option, when passing sensitive data to child module *to prevent storing the value state files*

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

| Provisioner       | Description                                                          |
| ----------------- | -------------------------------------------------------------------- |
| **`file`**        | Uploads files/directories to the remote resource (via SSH or WinRM). |
| **`local-exec`**  | Runs a local shell command on the **machine running Terraform**.     |
| **`remote-exec`** | Runs commands **on the remote resource** (via SSH or WinRM).         |

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
terraform init -migrate-state
terraform init -reconfigure
terraform init -backend-config=bucket="mybucket"
terraform init -backend-config="backend1.hcl"


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

terraform show                      # Show the Current State (Human-Readable)
terraform show plan.tfplan
terraform show -json plan.tfplan

terraform workspace list
terraform workspace show
terraform workspace new prod
terraform workspace select dev
terraform workspace delete dev

terraform fmt                 # formate the configuration in better formate 
terraform fmt -recursive

terraform refresh             # Updates Terraform’s state file to reflect the real-world infra
terraform get                 # Download and update Terraform modules
terraform console 
terraform graph
terraform taint <resource>    # Mark a resoure for recreation in the next apply 
terraform import <resource> <id>
terraform validate            # Validate the current configuration
```


# Exam List missingparts

## Part 1 (Terraform fundamentals)✅
### Providers
- Plugins called providers to interact with cloud providers, SaaS providers, and other APIs
- Each provider adds a set of resource types & data sources that Terraform can manage.
- Come from Terraform Registry or custom locals ones.

### Versions
- `required_providers` for provider versions.
- `required_version` for  controlling which Terraform CLI version is allowed to run your code. 

## Part 2 (Core Terraform workflow)✅
### Core Terraform Workflow
1. Write - Author infrastructure as code.
2. Initialize - prepares your workspace so Terraform can apply your configuration.
3. Plan - Preview changes before applying.
4. Apply - Provision reproducible infrastructure.

- Work As A Team:
  - write in a branch → review a plan → apply after approval.
  - the core workflow for teams is `a loop that plays out for each change`.

### terraform main Commands
#### `init`
- `3` main tasks it does:
  1. Backend Initialization (*remote/local*)
  2. Provider Plugin Installation: (*update/install*) && (Lock_file)
  3. Module Installation: (*update/install*)

- `Flags`
```bash
terraform init -upgrade -reconfigure      # Force Upgrades providers & modules Re-initializes the backend and ignores existing settings
terraform init -migrate-state             # it migrate state to new backend config
```
#### `validate`
- a local, fast syntax and logic checker for your Terraform code.

#### `graph`
- turns your infrastructure into a visual map

#### `plan`

| Flag                | Description                                  | Example                                   |
| ------------------- | -------------------------------------------- | ----------------------------------------- |
| `-out=FILE`         | Save the plan to a file for later apply.     | `terraform plan -out=tfplan`              |
| `-var="key=value"`  | Pass variable directly from CLI.             | `terraform plan -var="env=dev"`           |
| `-var-file=FILE`    | Load variables from a file.                  | `terraform plan -var-file=dev.tfvars`     |
| `-target=RESOURCE`  | Plan only for a specific resource.           | `terraform plan -target=aws_instance.web` |
| `-refresh=false`    | Skip refreshing real infrastructure state.   | `terraform plan -refresh=false`           |
| `-destroy`          | Show a plan that will destroy all resources. | `terraform plan -destroy`                 |
| `-compact-warnings` | Shorter warning messages.                    | `terraform plan -compact-warnings`        |
| `-parallelism=N`    | Limit parallelism during refresh.            | `terraform plan -parallelism=5`           |

#### `apply`
```bash
terraform apply -var="region=us-east-1" -var="env=prod"
terraform apply -var-file="prod.tfvars"
terraform apply -replace="aws_instance.my_server"
terraform apply -target="aws_s3_bucket.my_bucket"
terraform apply -input=false -auto-approve       
```

#### `destroy`
```bash
terraform destroy
terraform apply -destroy
```

#### `fmt`
| Flag           | What it Does                                                            |
| -------------- | ----------------------------------------------------------------------- |
| `-recursive`   | Format files in **subdirectories** too.                                 |
| `-check`       | **Check** if files are already formatted (exit 0 if yes). Useful in CI. |
| `-diff`        | Show **differences** without changing files.                            |
| `-write=false` | Don’t overwrite files (implied with `-check`).                          |
| `-list=false`  | Don’t list files with formatting issues.                                |


## Part 3 (Terraform configuration)✅

| Item                              | `init` | `plan` | `apply` |
| --------------------------------- | ------ | ------ | ------- |
| Provider config                   | ✅      | ✅      | ✅       |
| Backend config                    | ✅      | ✅      | ✅       |
| Module sources                    | ✅      | ✅      | ✅       |
| Variables                         | ❌      | ✅      | ✅       |
| Locals                            | ❌      | ✅      | ✅       |
| `for_each` / `count` collections  | ❌      | ✅      | ✅       |
| Resource arguments (from vars)    | ❌      | ✅      | ✅       |
| Apply-time attributes (IDs, ARNs) | ❌      | ❌      | ✅       |
| Outputs using computed values     | ❌      | ❌      | ✅       |

- The critical rule:
👉 Anything that determines structure — like how many resources, or their names — must be known before plan.


### Variables
```hcl
variable "<LABEL>" {
  type        = TYPE
  default     = <DEFAULT_VALUE>
  description = "<DESCRIPTION>"
  sensitive   = <true|false>
  nullable    = <true|false>
  ephemeral   = <true|false>

  validation {
    condition     = <EXPRESSION>
    error_message = "<ERROR_MESSAGE>"
  }
}
```
- The ephemeral argument is useful for values that only exist temporarily, such as a short-lived token or session identifier.
- The sensitive argument prevents Terraform from showing a variable block's value in CLI output when you use that variable in your configuration.

### Validation
- Terraform offers several ways of validating configuration:

#### input variable validation
- `Input variable` validations verify your ***configuration's parameters*** when Terraform creates a plan.
1. Verify input variables meet specific format requirements.
2. Verify input values fall within acceptable ranges.
3. Prevent Terraform operations if a variable is misconfigured.

```hcl
variable "image_id" {
  type        = string
  description = "The id of the machine image (AMI) to use for the server."

  validation {
    condition     = length(var.image_id) > 4 && substr(var.image_id, 0, 4) == "ami-"
    error_message = "The image_id value must be a valid AMI id, starting with \"ami-\"."
  }
}
```

#### preconditions and postconditions
- Preconditions ensure individual `resources, data sources, and outputs` meet your requirements before Terraform tries to create them.
  - verify your ***configuration's assumptions*** for resources, data sources, and outputs before Terraform creates them
- Postconditions verifies that Terraform produced your `resources and data sources` with the expected and desired settings.
  - serve as static guardrails to enforce mandatory configuration aspects on your data and resource blocks. 
```hcl 
output "instance_public_ip" {
  value = aws_instance.web.public_ip

  precondition {
    condition     = length([for rule in aws_security_group.web.ingress : rule if rule.to_port == 80 || rule.to_port == 443]) > 0
    error_message = "Security group must allow HTTP (port 80) or HTTPS (port 443) traffic."
  }
}

data "aws_ami" "example" {
  id = var.aws_ami_id

  lifecycle {
    # The AMI ID must refer to an existing AMI that has the tag "nomad-server".
    postcondition {
      condition     = self.tags["Component"] == "nomad-server"
      error_message = "tags[\"Component\"] must be \"nomad-server\"."
    }
  }
}

```

> ####  To decide between a precondition or a postcondition, consider whether the rule you are setting represents:
- an assumption you need to make about the configuration
  - Use preconditions for assumptions that you want to verify before Terraform creates the target block.
- or a guarantee on the resulting resource, and when it should run. 
  - Use postconditions for guarantees that you need to verify after Terraform creates the resource or reads from the data source

####  check blocks
- Use the check block to validate your infrastructure outside of the typical resource lifecycle. 
- When a check block's assertion fails, Terraform reports a warning and continues executing the current operation.
  - Validate resources, data sources, variables, or outputs in your configuration.
  - Validate the behavior of your infrastructure as a whole.
  - Verify infrastructure configuration without blocking operations.

```hcl
check "health_check" {
  data "http" "terraform_io" {
    url = "https://www.terraform.io"
  }

  assert {
    condition = data.http.terraform_io.status_code == 200
    error_message = "${data.http.terraform_io.url} returned an unhealthy status code"
  }
}
```
#### ***`Order of validation`***
1. Terraform executes input variable validations immediately, before generating a plan.
2. Terraform executes preconditions after generating a plan but before creating the resource, data source, or output.
3. Terraform executes postconditions after planning and applying changes.
4. Terraform executes checks at the end of plan and apply operations and every time health assessments run on a workspace in HCP Terraform.

<div style="text-align: center;">
<img src="./validation-order-of-operations-dark.jpg" alt="Jenkins" width="700" height="450" style="border-radius: 15px;">
</div>


### Resources

| Type                            | Syntax                                        |
| ------------------------------- | --------------------------------------------- |
| Resource                        | `resource_type.name`                          |
| Resource attribute              | `resource_type.name.attribute`                |
| Resource with count (index)     | `resource_type.name[0].attribute`             |
| Resource with count (all)       | `resource_type.name[*].attribute`             |
| Resource with for_each (by key) | `resource_type.name["key"].attribute`         |
| Resource with for_each (all)    | `[for r in resource_type.name : r.attribute]` |
| Input variable                  | `var.name`                                    |
| Local value                     | `local.name`                                  |
| Module output                   | `module.module_name.output_name`              |
| Data source                     | `data.data_type.name.attribute`               |
| Nested block (list)             | `resource_type.name.block[*].attribute`       |
| Nested block (map by key)       | `resource_type.name.block["key"].attribute`   |
| Path (module)                   | `path.module`                                 |
| Path (root)                     | `path.root`                                   |
| Path (cwd)                      | `path.cwd`                                    |
| Workspace                       | `terraform.workspace`                         |
| Count index                     | `count.index`                                 |
| Each key                        | `each.key`                                    |
| Each value                      | `each.value`                                  |
| Self                            | `self.attribute`                              |
| Values (from map)               | `values(resource_type.name)[*].attribute`     |

### Types
- We have 3 main types:

### 1. Primitive Types
- *Primitive types* : a simple type that isn't made from any other types
- we have 3 primitive types:
  - `string`
  - `number`
  - `bool`

### 2. Collection Types
- *collection type*: a type allows multiple values of one other type to be grouped together as a single value.
- we have 3 collection types:
  - `lists` ( Ordered, indexable, Duplicates allowed)
  - `maps`  ( Key-value pairs, Accessed by key)
  - `sets`  ( Unordered, unique )

- list([ value, value ]):
  - example: **list_ex = ["apple", "banana", "cherry"]**
  - allow duplicate, ordered -> can access specific value: **value[0]**
  - works with ***count & for_each & for*** "order doesn't matter"
  - access:
    - list.index
    - list[index]
    - list["index"]

- set([ unique_value, unique_value ]):
  - example: **set_ex = ["apple", "banana", "cherry"]**
  - unique, no index -> can't access specific value
  - access works with ***for_each & for*** "order doesn't matter"

- map({ KEY = TYPE }):
  - example: **map = {"name" = "kary", "age" = "15"}**
  - keys in a map must be strings & unique
  - key & value by **:** or **=**, element & other by **,** or linespace
  - ***for_each*** -> ***each.key each.value***
  - `dynamic maps` { for key, value in var.my_map : key => upper(value) }
  - access:
    - map.key
    - map[key]
    - map["key"]

### 3. Structural Types
- we have 2 types:
  - `object`
  - `tuple`

- object({ KEY = TYPE })
  - objects like typed maps.
  - Keys must be defined ahead of time
  - You can make certain attributes ***optional(TYPE,default)*** in object definitions
  - access like maps

- tuple([ string, number, bool ])
  - fixed-length collection where each element can be a different type.

### 4. Dynamic Types
- any

### Loops
- `for_each`:
  - Terraform expects either a map or a set (normal)
  - We use it to create multiple resources/data based on a map/set
  - map -> `each.key & each.value`
  - set -> `each.key || each.value`



## Part 4-b (Terraform state management)✅
### Refactor Terraform state:
- when we reorganize our resources like moving ownership or split big project

- We should group the resources based on:
  1. rate of change
  2. stateless/stateful
  3. Access and team responsibility

### Migrate resources
- Steps:
  1. take backup of state
  2. remove from state use **removed // state rm**
  3. add to the now state using **import**
- we can use script that we define what to import and what to remove then we `apply`
```hcl
resource "aws_instance" "example" {
    instance_type = "t3.micro"
    ami = data.aws_ami.example.id
}
removed {
  from = aws_instance.example
  lifecycle {
    destroy = false
  }
}
import {
id = "i-07b510cff5f79af00"
to = aws_instance.example
}
moved {
    from = <old address for the resource>
    to = <new address for the resource>
}

```
- We also can se commands only 
```bash
terraform state rm <resources.id>
terraform import <resources> <id>
```
- Other method (**Dangerous**)
  - pull the state from project-old/project-new
  - use state mv -state -state-out
  - push the state to project-old/project-new

```bash
terraform state pull > source.tfstate
terraform state pull > destination.tfstate
terraform state mv -state source/source.tfstate -state-out destination/destination.tfstate aws_instance.example aws_instance.example
terraform state push source.tfstate
terraform state push destination.tfstate
```

## Part 5 (Maintain infrastructure with Terraform)✅
### Import
- we can import into:
  - resources 
  - modules 
  - resources configured with count/for_each
```bash
terraform import aws_instance.foo i-abcd1234
terraform import module.foo.aws_instance.bar i-abcd1234
terraform import 'aws_instance.baz[0]' i-abcd1234
terraform import 'aws_instance.baz["example"]' i-abcd1234
```

### Import order
#### Method 1
1. create a place holder config 
2. run import command 
3. Inspect the imported state ( to see the real attributes)
4. update your config to match your desire config (existing/updating)
5. run plan (no wanted changes -> show noting to plan/ updating -> show plan to be applied  )

#### Method 2
1. create import block
2. (Optional) Generate the config
3. plan then apply

```hcl
import {
  to = docker_container.web
  id = "abcd1234"
}
```
```bash
terraform plan -generate-config-out=generated.tf
```

### Logs

| Variable              | Purpose                                           | Example                    |
| --------------------- | ------------------------------------------------- | ---------------------------|
| **`TF_LOG`**          | Enables global logging (core + providers)         | `TF_LOG=DEBUG`             |
| **`TF_LOG_CORE`**     | Logs only Terraform core engine internals         | `TF_LOG_CORE=TRACE`        |
| **`TF_LOG_PROVIDER`** | Logs only provider plugin activity                | `TF_LOG_PROVIDER=DEBUG`    |
| **`TF_LOG_PATH`**     | Saves logs to a file instead of stdout            | `TF_LOG_PATH=terraform.log`|

## Part 6 (HCP Terraform)
<div style="text-align: center;">
<img src="./hcp.avif" alt="Jenkins" width="1100" height="500" style="border-radius: 15px;">
</div>

### HCP Terraform Overview
- HCP Terraform is an application that helps teams use Terraform together.

### Workflow
- HCP Terraform organizes your resources into workspaces, which contain your resource definitions, environment and input variables, and state files.
  - VCS-driven workflow
  - CLI-driven workflow
  - API-driven workflow

- HCP Terraform organizes infrastructure into ***`projects`*** that contain workspaces and Stacks.:
  - `Workspaces` are ideal for managing a self-contained infrastructure of one Terraform root module.
  - `Stacks` are ideal for managing multiple infrastructure modules and repeating that infrastructure at scale.

### HCP Workspaces
- A workspace is a group of infrastructure resources managed by Terraform.
- workspace in HCP act as a container directory for configuration

### HCP Terraform workspaces and local working directories

| Component                   | Local Terraform                | HCP Terraform           |
|-----------------------------|--------------------------------|-------------------------|
| **Terraform configuration** | On disk                        | In VCS Repo             |
| **Variable values**         | As `.tfvars` files, arge , env | In workspace            |
| **State**                   | On disk or in remote backend   | In workspace            |
| **Credentials and secrets** | In shell env or as prompts     | In workspace, stored as sensitive variables  |
| **Runs**                    | on local machine               | remote operations (the default) |

- Workspace Health
  - `Drift detection` determines whether your real-world infrastructure matches your Terraform configuration.
  - `Continuous validation` determines whether custom conditions in the workspace’s configuration continue to pass after Terraform provisions the infrastructure.


### Remote operations
- HCP Terraform is designed as an execution platform for Terraform, and can perform Terraform runs on its own disposable virtual machines.
- HCP execution options:
  - remote 
  - local
  - agent
- `Terraform's features` *rely on remote execution and are not available when using local operations*. This includes features like **Sentinel policy enforcement, cost estimation, and notifications.**


### Variables 
- variable sets: collection of variables that accessible within the entire project (group of workspaces)

- we can use the workspace variables and outputs to work with other workspaces
```hcl
data "tfe_outputs" "source_workspace" {
  workspace    = var.workspace_name
  organization = var.organization_name
}
```

- The `explorer` for workspace visibility helps surface a wide range of valuable information from across your organization.

- `policy rules` for the *plan*, *configuration*, *state*, and *run* associated with a policy check.

- **OPA** `Open Policy Agent`: 

- `terraform_remote_state` only exposes output values, its user must have access to the entire state snapshot, which often includes some sensitive information.

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


## Filling gaps
### LifeCycle
### create_before_destroy
- Terraform will never break a dependency chain to honor create_before_destroy.
- If a dependency must be replaced first, Terraform will replace dependents first (destroy them) before proceeding.

### ignore_changes
- Hey Terraform, don’t try to manage or reconcile this specific field anymore.
- If it changes — either in the real infrastructure or in my config — pretend you didn’t see it

```hcl
 lifecycle {
   prevent_destroy = true
 }

 lifecycle {
   create_before_destroy = true
  }

 lifecycle {
   ignore_changes        = [tags]
  }

 lifecycle {
   replace_triggered_by  = [aws_security_group.web_sg]
 }
```



### cloudinit_config
- `cloudinit_config` is a Terraform ***data source*** (not a resource) that helps you generate and package cloud-init
 user data for virtual machines.
- a Terraform `helper` that simplifies building complex, ***multi-part user_data payloads*** for virtual machines.

| Argument     | Purpose     |
| ------------ | ----------- |
| `gzip`  | (Optional) Compress the final output. Defaults to `false`.|
| `base64_encode` | (Optional) Whether to base64-encode the output (required by some providers like AWS). Defaults to `true`. |
| `part {}`           | One or more configuration parts to include in the final user_data.        |
| `part.content_type` | MIME type for this part (e.g., `text/cloud-config`, `text/x-shellscript`) |
| `part.content`      | The actual script or config content.   |


```hcl
data "cloudinit_config" "web_init" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = <<-EOC
      #cloud-config
      package_update: true
      packages:
        - nginx
        - curl
    EOC
  }

  part {
    content_type = "text/x-shellscript"
    content      = <<-EOS
      #!/bin/bash
      systemctl enable nginx
      systemctl start nginx
    EOS
  }
}

resource "aws_instance" "web" {
  ami           = "ami-123456"
  instance_type = "t3.micro"

  user_data = data.cloudinit_config.web_init.rendered
}

```


### Refactor
https://developer.hashicorp.com/terraform/language/modules/develop/refactoring

### upcomming notes sections
- ephemeral block
- null resources
- provisioners
- flatten & setproduct & chomp
- variable overrite order 
