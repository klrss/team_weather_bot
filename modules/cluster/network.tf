resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block_vpc
  instance_tenancy = "default"
  tags = {
    Name = "${var.app_name}-${var.environment}-vpc"
  }
}

resource "aws_subnet" "public" {
  count      =  var.az_count
  vpc_id     =  aws_vpc.main.id
  cidr_block =  cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.app_name}-${var.environment}-subnet-public"
  }
}

resource "aws_subnet" "private" {
  count      =  var.az_count
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + var.az_count)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.app_name}-${var.environment}-subnet-private"
  }
}

resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.main.id
    tags = {
    Name = "${var.app_name}-${var.environment}-gw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  count = var.az_count
  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "${var.app_name}-${var.environment}-public-rt"
  }
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table_association" "routeTableAssociationPublicRoute" {
  depends_on = [aws_route_table.public]
  count = var.az_count
  subnet_id     = aws_subnet.public[count.index].id
  route_table_id =aws_route_table.public[count.index].id
}


resource "aws_eip" "gw" {
    depends_on = [aws_internet_gateway.gw] 
    count      =  var.az_count
    vpc = true
    tags = {
    Name = "${var.app_name}-${var.environment}-eip"
  }
}

resource "aws_nat_gateway" "gateway" {
  depends_on = [aws_eip.gw]
  count         =  var.az_count
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.gw.*.id, count.index)
  tags = {
    Name = "${var.app_name}-${var.environment}-nat-${data.aws_availability_zones.available.names[count.index]}"
  }
}


resource "aws_route_table" "private" {
  depends_on = [aws_nat_gateway.gateway]
  count  =      var.az_count
  vpc_id =      aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = element(aws_nat_gateway.gateway.*.id, count.index)
  }
  tags = {
    Name = "${var.app_name}-${var.environment}-private-rt"
  }
}


resource "aws_route_table_association" "private" {
  depends_on = [aws_route_table.private]
  count = var.az_count
  subnet_id     = element(aws_subnet.private.*.id, count.index)
  route_table_id =element(aws_route_table.private.*.id, count.index)
}
