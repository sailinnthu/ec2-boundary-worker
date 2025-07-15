#------------------------------------------------------------------------------
# VPC
#------------------------------------------------------------------------------
resource "aws_vpc" "main" {
  count = var.create_vpc ? 1 : 0

  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    { Name = "${var.friendly_name_prefix}-${var.vpc_name}" },
    var.common_tags
  )
}

#------------------------------------------------------------------------------
# Subnets
#------------------------------------------------------------------------------
resource "aws_subnet" "public" {
  count = var.create_vpc ? length(var.public_subnet_cidrs) : 0

  vpc_id                  = aws_vpc.main[0].id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = merge(
    { Name = "${var.friendly_name_prefix}-public-${element(data.aws_availability_zones.available.names, count.index)}" },
    var.common_tags
  )
}

resource "aws_subnet" "private" {
  count = var.create_vpc ? length(var.private_subnet_cidrs) : 0

  vpc_id                  = aws_vpc.main[0].id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = false

  tags = merge(
    { Name = "${var.friendly_name_prefix}-private-${element(data.aws_availability_zones.available.names, count.index)}" },
    var.common_tags
  )
}

#------------------------------------------------------------------------------
# Internet Gateway
#------------------------------------------------------------------------------
resource "aws_internet_gateway" "igw" {
  count = var.create_vpc ? 1 : 0

  vpc_id = aws_vpc.main[0].id

  tags = merge(
    { Name = "${var.friendly_name_prefix}-igw" },
    var.common_tags
  )
}

#------------------------------------------------------------------------------
# Elastic IPs
#------------------------------------------------------------------------------
resource "aws_eip" "nat_eip" {
  count = var.create_vpc && length(var.public_subnet_cidrs) > 0 ? length(var.public_subnet_cidrs) : 0

  #vpc        = true
  depends_on = [aws_internet_gateway.igw]

  tags = merge(
    { Name = "${var.friendly_name_prefix}-nat-eip" },
    var.common_tags
  )
}

#------------------------------------------------------------------------------
# NAT Gateways
#------------------------------------------------------------------------------
resource "aws_nat_gateway" "ngw" {
  count = var.create_vpc && length(var.public_subnet_cidrs) > 0 ? length(var.public_subnet_cidrs) : 0

  allocation_id = element(aws_eip.nat_eip.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  # depends_on = [
  #   aws_internet_gateway.igw,
  #   aws_eip.nat_eip,
  #   aws_subnet.public,
  # ]

  tags = merge(
    { Name = "${var.friendly_name_prefix}-ngw-${count.index}" },
    var.common_tags
  )
}

#------------------------------------------------------------------------------
# Route Tables & Routes
#------------------------------------------------------------------------------
resource "aws_route_table" "rtb_public" {
  count = var.create_vpc ? 1 : 0

  vpc_id = aws_vpc.main[0].id

  depends_on = [aws_internet_gateway.igw]

  tags = merge(
    { Name = "${var.friendly_name_prefix}-rtb-public" },
    var.common_tags
  )
}

resource "aws_route" "route_public" {
  count = var.create_vpc ? 1 : 0

  route_table_id         = aws_route_table.rtb_public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id
}

resource "aws_route_table" "rtb_private" {
  count = var.create_vpc ? length(var.private_subnet_cidrs) : 0

  vpc_id = aws_vpc.main[0].id

  depends_on = [aws_nat_gateway.ngw]

  tags = merge(
    { Name = "${var.friendly_name_prefix}-rtb-private-${count.index}" },
    var.common_tags
  )
}

resource "aws_route" "route_private" {
  count = var.create_vpc ? length(var.private_subnet_cidrs) : 0

  route_table_id         = element(aws_route_table.rtb_private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.ngw.*.id, count.index)
}

resource "aws_route_table_association" "rtbassoc-public" {
  count = var.create_vpc ? length(var.public_subnet_cidrs) : 0

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.rtb_public[0].id
}

resource "aws_route_table_association" "rtbassoc-private" {
  count = var.create_vpc ? length(var.private_subnet_cidrs) : 0

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.rtb_private.*.id, count.index)
}

