resource "aws_vpc" "General_vpc" {
  cidr_block           = var.cidr
  instance_tenancy     = "default"
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(var.tags,
    {
      Name = "${var.name}"
    }
  )
}

#------------------------------------------- Public
locals {
  create_public_subnets = length(var.public_subnets) > 0 && length(var.azs) == length(var.public_subnets) ? true : false
}

resource "aws_subnet" "public_subnets" {

  count             = local.create_public_subnets ? length(var.public_subnets) : 0
  cidr_block        = var.public_subnets[count.index]
  availability_zone = element(var.azs, count.index)
  vpc_id            = aws_vpc.General_vpc.id

  tags = merge(var.tags,
    {
      Name = "${var.name}-public-subnet-${count.index + 1}"
    }
  )
}

resource "aws_internet_gateway" "gw" {
  count  = local.create_public_subnets ? 1 : 0
  vpc_id = aws_vpc.General_vpc.id

  tags = merge(var.tags,
    {
      Name = "${var.name}-igw"
    }
  )
}

resource "aws_route_table" "public_rt" {
  count  = local.create_public_subnets ? 1 : 0
  vpc_id = aws_vpc.General_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw[0].id
  }

  tags = merge(var.tags,
    {
      Name = "${var.name}-public-rt"
    }
  )
}

resource "aws_route_table_association" "public_assoc" {
  count          = local.create_public_subnets ? length(var.public_subnets) : 0
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt[0].id
}

#------------------------------------------- Private

locals {
  create_private_subnets = length(var.private_subnets) > 0 ? true : false
}

resource "aws_subnet" "private_subnets" {
  count             = local.create_private_subnets ? length(var.private_subnets) : 0
  cidr_block        = var.private_subnets[count.index]
  availability_zone = element(var.azs, count.index % length(var.azs))
  vpc_id            = aws_vpc.General_vpc.id

  tags = merge(var.tags,
    {
      Name = "${var.name}-private-subnet-${count.index + 1}"
    }
  )
}

locals {
  Number_of_nat_gw = var.nat_gateway == "single" ? 1 : (var.nat_gateway == "perAZ" ? length(var.azs) : 0)
}

resource "aws_eip" "elastic_ip" {
  count  = local.create_public_subnets ? local.Number_of_nat_gw : 0
  domain = "vpc"

  tags = merge(
    var.tags,
    { Name = "${var.name}-eip-${count.index + 1}" }
  )
}

resource "aws_nat_gateway" "NAT_GW" {
  count         = local.create_public_subnets ? local.Number_of_nat_gw : 0
  allocation_id = aws_eip.elastic_ip[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id
  depends_on    = [aws_internet_gateway.gw]
  tags = merge(var.tags,
    {
      Name = "${var.name}-nat-gw-${count.index + 1}"
    }
  )
}

resource "aws_route_table" "private_rt" {
  count  = local.create_private_subnets ? length(var.azs) : 0
  vpc_id = aws_vpc.General_vpc.id

  dynamic "route" {
    for_each = local.Number_of_nat_gw > 0 ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.NAT_GW[local.Number_of_nat_gw == 1 ? 0 : count.index].id
    }
  }

  tags = merge(var.tags,
    {
      Name = "${var.name}-private-rt-${count.index + 1}-${var.azs[count.index]}"
    }
  )
}

resource "aws_route_table_association" "private_assoc" {
  count          = local.create_private_subnets ? length(var.private_subnets) : 0
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rt[count.index % length(var.azs)].id
}
