# vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "portfolio-vpc"
  }
}

# public subnets
resource "aws_subnet" "public_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"
  tags              = { Name = "portfolio-public-1a" }
}

resource "aws_subnet" "public_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1c"
  tags              = { Name = "portfolio-public-1c" }
}

# private subnets
resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "ap-northeast-1a"
  tags              = { Name = "portfolio-private-1a" }
}

resource "aws_subnet" "private_1c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "ap-northeast-1c"
  tags              = { Name = "portfolio-private-1c" }
}

# ---- Osaka Region ----

# osaka vpc 10.1.0.0/16
resource "aws_vpc" "osaka_main" {
  provider   = aws.osaka # 重要
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "portfolio-vpc-osaka"
  }
}

/*
# fetch osakas available az (pending)
data "aws_availability_zones" "osaka_az" {
  provider = aws.osaka
  state    = "available"
}
*/

# osaka public subnets
resource "aws_subnet" "osaka_public_3a" {
  provider          = aws.osaka
  vpc_id            = aws_vpc.osaka_main.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "ap-northeast-3a" # とりあえず直接
  tags              = { Name = "portfolio-osaka-public-3a" }
}

resource "aws_subnet" "osaka_public_3c" {
  provider          = aws.osaka
  vpc_id            = aws_vpc.osaka_main.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = "ap-northeast-3c"
  tags              = { Name = "portfolio-osaka-public-3c" }
}

# osaka private subnets
resource "aws_subnet" "osaka_private_3a" {
  provider          = aws.osaka
  vpc_id            = aws_vpc.osaka_main.id
  cidr_block        = "10.1.11.0/24"
  availability_zone = "ap-northeast-3a"
  tags              = { Name = "portfolio-osaka-private-3a" }
}

resource "aws_subnet" "osaka_private_3c" {
  provider          = aws.osaka
  vpc_id            = aws_vpc.osaka_main.id
  cidr_block        = "10.1.12.0/24"
  availability_zone = "ap-northeast-3c"
  tags              = { Name = "portfolio-osaka-private-3c" }
}

# tokyo igw
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "portfolio-igw"
  }
}

# osaka igw
resource "aws_internet_gateway" "osaka" {
  provider = aws.osaka
  vpc_id   = aws_vpc.osaka_main.id

  tags = {
    Name = "portfolio-igw-osaka"
  }
}

# tokyo route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = { Name = "portfolio-public-rt" }
}

# assoc route table  to public subnet 1a
resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

# assoc route table to public subnet 1c
resource "aws_route_table_association" "public_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public.id
}

# osaka route table
resource "aws_route_table" "osaka_public" {
  provider = aws.osaka
  vpc_id   = aws_vpc.osaka_main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.osaka.id
  }

  tags = { Name = "portfolio-osaka-public-rt" }
}

# assoc route table to public subnet 3a
resource "aws_route_table_association" "osaka_public_3a" {
  provider       = aws.osaka
  subnet_id      = aws_subnet.osaka_public_3a.id
  route_table_id = aws_route_table.osaka_public.id
}

# assoc route table to public subnet 3c
resource "aws_route_table_association" "osaka_public_3c" {
  provider       = aws.osaka
  subnet_id      = aws_subnet.osaka_public_3c.id
  route_table_id = aws_route_table.osaka_public.id
}
