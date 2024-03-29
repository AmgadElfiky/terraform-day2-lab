# VPC
resource "aws_vpc" "vpc1" {
  cidr_block = var.aws_vpc

  tags = {
    Name = "vpc1"
  }
}
# internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "vpc_igw"
  }
}
# public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = var.aws_subnet
  map_public_ip_on_launch = true
  availability_zone       = var.AZ
  tags = {
    Name = "public-subnet"
  }
}
# Create an Elastic IP for NAT Gateway
resource "aws_eip" "public_subnet" {
  # vpc = true
  domain = "vpc"
}
# Create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.public_subnet.id
  subnet_id     = aws_subnet.public_subnet.id
}
# private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = var.private_subnet
  availability_zone = var.AZ
  tags = {
    Name = "private-subnet"
  }
}
# route table for public
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc1.id
  route {
    cidr_block = var.CIDR_block_route
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public_rt"
  }
}
# Create route table for private subnet
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.vpc1.id
}

# Associate private subnet with private route table
resource "aws_route_table_association" "private-rt" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private-rt.id
}

# Add route to direct traffic to NAT Gateway in the private route table
resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private-rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}
# conncetion
resource "aws_route_table_association" "public_rt_asso" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

