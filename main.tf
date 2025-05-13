# vpc creation

resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default" # instance tenancy is common for vpc
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    var.common_tags,
    {
        Name = local.resource_name
    }
    )
}
# intenet gateway creation and attacthed to the vpc
resource "aws_internet_gateway" "main"{
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.igw_tags,
    {
        Name = local.igw_name
    }
  )
}

# creating 2 public subnets in 2 availabiltiy zone for high availability purpose

resource "aws_subnet" "public" {
    count = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true 
  tags = mergev{
    var.common_tags,
    var.public_subnet_tags,
    {
      Name = "${local.resourec_name}-public-${local.az_names[count.index]}"
    }
  }
}

# creating 2 private subnets in 2 availability zones

resource "aws_subnet" "private" {
    count = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]
  tags = merge{
    var.common_tags,
    var.private_subnet_tags,
    {
      Name = "${local.resourec_name}-private-${local.az_names[count.index]}"
    }
  }
}


# creating 2  database-private subnets in 2 availability zones

resource "aws_subnet" "database" {
    count = length(var.database_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]
  tags = merge{
    var.common_tags,
    var.database_subnet_tags,
    {
      Name = "${local.resourec_name}-database-${local.az_names[count.index]}"
    }
  }
}

# creating elastic ip for NAT gateway

resource "aws_eip" "nat" {
  
  domain   = "vpc"
}

# creation of NAT gateway
# NAT gateway must should available in public subnet

resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id # it will take the 1st public subnet

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}

# creation of public route table 

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id


  tags = merge(
      var.public_route_table_tags,
     {
    Name = "Public-route table"
  }
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id


  tags = merge(
    var.private_route_table_tags,
   {
    Name = "Private-route table"
  }
  )
}


resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id


  tags = merge(
    var.database_route_table_tags,
  {
    Name = "database-route table"
  }
  )
}

# In public route-table entry should come from internet-gateway.
# Genereally in public route-table the traffic will come from internet-gateway so the route table will give a route to the internet gateway.

# creation of public-route-table &attaching internet gateway to the route table

resource "aws_route" "public-route" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

# creation of private-route-table & attaching to the NAT gateway to the private route-table.
resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.example.id
}

# creation of Database-route-table & attaching to the NAT gateway to the Database route-table.

resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.example.id
}


# Associtation of 2 public-subnets to the route table

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


# Associtation of 2 private-subnets to the route table

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}


# Associtation of 2 Database-subnets to the route table

resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}

