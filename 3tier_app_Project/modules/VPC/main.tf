# We need
# vpc
# subnets
# route table
# internet gateway
# ------------------------------------------- VPC
resource "aws_vpc" "General_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name        = "${var.vpc_name}-vpc"
    Owner       = var.vpc_owner
    Environment = var.vpc_env
  }
}

# ------------------------------------------- Subnet
resource "aws_subnet" "public_subnets" {
  vpc_id            = aws_vpc.General_vpc.id
  count             = length(var.public_subnets)
  cidr_block        = var.public_subnets[count.index]
  availability_zone = element(var.azs, count.index)

  tags = {
    Name        = "${var.vpc_name}-public-subnet-${count.index + 1}"
    Owner       = var.vpc_owner
    Environment = var.vpc_env
  }
}

resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.General_vpc.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = element(var.azs, count.index)

  tags = {
    Name        = "${var.vpc_name}-private-subnet-${count.index + 1}"
    Owner       = var.vpc_owner
    Environment = var.vpc_env
  }
}


# ------------------------------------------- Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.General_vpc.id

  tags = {
    Name        = "${var.vpc_name}-igw"
    Owner       = var.vpc_owner
    Environment = var.vpc_env
  }
}

# ------------------------------------------- Elastic IP for NAT Gateway
resource "aws_eip" "Elastic_IP" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"
  tags = {
    Name        = "${var.vpc_name}-Elastic-IP"
    Owner       = var.vpc_owner
    Environment = var.vpc_env
  }
}

resource "aws_nat_gateway" "NAT_GW" {
  count         = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.Elastic_IP[0].id
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = {
    Name        = "${var.vpc_name}-gw-NAT"
    Owner       = var.vpc_owner
    Environment = var.vpc_env
  }
  depends_on = [aws_internet_gateway.gw]
}

# ------------------------------------------- Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.General_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  

  tags = {
    Name        = "${var.vpc_name}-public-rt"
    Owner       = var.vpc_owner
    Environment = var.vpc_env
  }
}

# Associate route table with subnet
resource "aws_route_table_association" "public_assoc" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# ------------------------------------------- Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.General_vpc.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.NAT_GW[0].id
    }
  }

  tags = {
    Name        = "${var.vpc_name}-private-rt"
    Owner       = var.vpc_owner
    Environment = var.vpc_env
  }
}

# Associate route table with private subnets
resource "aws_route_table_association" "private_assoc" {
  count          = var.enable_nat_gateway ? length(var.private_subnets) : 0
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rt.id
}
