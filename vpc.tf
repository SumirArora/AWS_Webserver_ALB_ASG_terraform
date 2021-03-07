data "aws_availability_zones" "all" {}
#Create VPC
resource "aws_vpc" "test-vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "test-vpc"
  }
}

data "aws_availability_zones" "available" {}

#Create IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.test-vpc.id

  tags = {
    Name = "igw"
  }
}

resource "aws_eip" "nat" {
  vpc   = true
  count = length(var.subnet_cidrs_public)
  #depends_on = [aws_nat_gateway.natgw]
}

resource "aws_nat_gateway" "natgw" {
  count         = length(var.subnet_cidrs_public)
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public-subnet.*.id, count.index)

  tags = {
    Name      = "NAT Gateway"
    Terraform = true
  }
}
#Create route table
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.test-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

# Create subnet

resource "aws_subnet" "private-subnet" {
  count             = length(var.subnet_cidrs_private)
  vpc_id            = aws_vpc.test-vpc.id
  cidr_block        = var.subnet_cidrs_private[count.index]
  availability_zone = data.aws_availability_zones.all.names[count.index]
  #availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "private-subnet"
  }
}

resource "aws_subnet" "public-subnet" {
  count             = length(var.subnet_cidrs_public)
  vpc_id            = aws_vpc.test-vpc.id
  cidr_block        = var.subnet_cidrs_public[count.index]
  availability_zone = data.aws_availability_zones.all.names[count.index]
  #availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "public-subnet"
  }
}

#Create  private route table
resource "aws_route_table" "private-rt" {
  count  = 2 #length(var.subnet_cidrs_private)
  vpc_id = aws_vpc.test-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = element(aws_nat_gateway.natgw.*.id, count.index)
  }

  tags = {
    Name = "private-rt"
  }
}

#Associate private subnet with private Route table

resource "aws_route_table_association" "private" {
  count          = length(var.subnet_cidrs_private)
  subnet_id      = element(aws_subnet.private-subnet.*.id, count.index)
  route_table_id = element(aws_route_table.private-rt.*.id, count.index)
}

#Associate public subnets with public Route table

resource "aws_route_table_association" "public" {
  count          = length(var.subnet_cidrs_public)
  subnet_id      = element(aws_subnet.public-subnet.*.id, count.index)
  route_table_id = aws_route_table.public-rt.id
}
/*
data "aws_subnet_ids" "all" {
  vpc_id = aws_vpc.test-vpc.id
}*/