resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "${var.project_name}-vpc" }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project_name}-igw" }
}

resource "aws_subnet" "tier" {
  count                   = 12
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.subnet_cidrs[floor(count.index / 4)][count.index % 4]
  availability_zone       = local.azs[floor(count.index / 4)]
  map_public_ip_on_launch = count.index % 4 == 0
  tags = {
    Name = "${var.project_name}-${["public-web", "private-web", "private-app", "private-db"][count.index % 4]}-${substr(local.azs[floor(count.index / 4)], -1, 1)}"
    Tier = ["public-web", "private-web", "private-app", "private-db"][count.index % 4]
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "${var.project_name}-nat-eip" }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.tier[0].id
  depends_on    = [aws_internet_gateway.main]
  tags          = { Name = "${var.project_name}-nat" }
}

resource "aws_route_table" "public" {
  count  = 3
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = { Name = "${var.project_name}-public-rt-${substr(local.azs[count.index], -1, 1)}" }
}

resource "aws_route_table" "private_web_app" {
  count  = 3
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  tags = { Name = "${var.project_name}-private-web-rt-${substr(local.azs[count.index], -1, 1)}" }
}

resource "aws_route_table" "private_app" {
  count  = 3
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  tags = { Name = "${var.project_name}-private-app-rt-${substr(local.azs[count.index], -1, 1)}" }
}

resource "aws_route_table" "private_db" {
  count  = 3
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project_name}-private-db-rt-${substr(local.azs[count.index], -1, 1)}" }
}

resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = aws_subnet.tier[count.index * 4].id
  route_table_id = aws_route_table.public[count.index].id
}

resource "aws_route_table_association" "private_web" {
  count          = 3
  subnet_id      = aws_subnet.tier[count.index * 4 + 1].id
  route_table_id = aws_route_table.private_web_app[count.index].id
}

resource "aws_route_table_association" "private_app" {
  count          = 3
  subnet_id      = aws_subnet.tier[count.index * 4 + 2].id
  route_table_id = aws_route_table.private_app[count.index].id
}

resource "aws_route_table_association" "private_db" {
  count          = 3
  subnet_id      = aws_subnet.tier[count.index * 4 + 3].id
  route_table_id = aws_route_table.private_db[count.index].id
}
