# provider aws
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# tokyo region
provider "aws" {
  region = "ap-northeast-1"
}

# osaka region
provider "aws" {
  alias  = "osaka"
  region = "ap-northeast-3"
}

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
  provider   = aws.osaka  # 重要
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "portfolio-vpc-osaka"
  }
}

/*
# fetch osakas available az 保留
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

# assoc rt to pubsub 1a
resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

# assoc rt to pubsub 1c
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

# assoc rt to pubsub 3a
resource "aws_route_table_association" "osaka_public_3a" {
  provider       = aws.osaka
  subnet_id      = aws_subnet.osaka_public_3a.id
  route_table_id = aws_route_table.osaka_public.id
}

# assoc rt to pubsub 3c
resource "aws_route_table_association" "osaka_public_3c" {
  provider       = aws.osaka
  subnet_id      = aws_subnet.osaka_public_3c.id
  route_table_id = aws_route_table.osaka_public.id
}


# tokyo security group
resource "aws_security_group" "tokyo_web_sg" {
  name        = "portfolio-web-sg"
  vpc_id      = aws_vpc.main.id

  # allow http
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

/*
  # ssh 22 (specify my ip later)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
*/

  # allow all egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "portfolio-web-sg" }
}

# osaka security group
resource "aws_security_group" "osaka_web_sg" {
  provider    = aws.osaka
  name        = "portfolio-osaka-web-sg"
  vpc_id      = aws_vpc.osaka_main.id

  # allow http
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

/*
# ssh 22 (specify my ip later)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
*/

# allow all egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "portfolio-osaka-web-sg" }
}

# tokyo latest amazon linux 2023 id
data "aws_ssm_parameter" "amzn2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

# launch tokyo web server
resource "aws_instance" "tokyo_web" {
  ami           = data.aws_ssm_parameter.amzn2023_ami.value
  instance_type = "t3.micro"

  # force public ip
  associate_public_ip_address = true

  # subnet 1a
  subnet_id = aws_subnet.public_1a.id
  
  # attach security grp
  vpc_security_group_ids = [aws_security_group.tokyo_web_sg.id]

  # init sh (install apache)
  user_data = <<-EOF
              #!/bin/bash
              dnf install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>tokyo 1a</h1>" > /var/www/html/index.html
              EOF

  tags = { Name = "portfolio-tokyo-web" }
}



# osaka latest amazon linux 2023 id
data "aws_ssm_parameter" "osaka_amzn2023_ami" {
  provider = aws.osaka
  name     = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

# launch osaka web server
resource "aws_instance" "osaka_web" {
  provider                    = aws.osaka
  ami                         = data.aws_ssm_parameter.osaka_amzn2023_ami.value
  instance_type               = "t3.micro"

# force public ip
  associate_public_ip_address = true

# subnet 1a
  subnet_id              = aws_subnet.osaka_public_3a.id

# attach security grp
  vpc_security_group_ids = [aws_security_group.osaka_web_sg.id]

# init sh (install apache)
  user_data = <<-EOF
              #!/bin/bash
              dnf install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>osaka 3a</h1>" > /var/www/html/index.html
              EOF

  tags = { Name = "portfolio-osaka-web" }
}

# dns: make "portfolio" subdomain zone
resource "aws_route53_zone" "portfolio_sub" {
  name = "portfolio.vexations.org"
}

# show ns
output "portfolio_ns" {
  value = aws_route53_zone.portfolio_sub.name_servers
}

# show pub ip tokyo instance
output "tokyo_web_public_ip" {
  value = "http://${aws_instance.tokyo_web.public_ip}"
}

# show pub ip oskaka instance
output "osaka_web_public_ip" {
  value = "http://${aws_instance.osaka_web.public_ip}"

}

# tokyo health check (要検討)
resource "aws_route53_health_check" "tokyo_health" {
  ip_address        = aws_instance.tokyo_web.public_ip
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = "3" # three strikes
  request_interval  = "30"

  tags = { Name = "tokyo-health-check" }
}

# tokyo record (primary)
resource "aws_route53_record" "portfolio_primary" {
  zone_id = aws_route53_zone.portfolio_sub.zone_id
  name    = "portfolio.vexations.org"
  type    = "A"
  
  # failover stuff
  failover_routing_policy {
    type = "PRIMARY"
  }

  set_identifier  = "tokyo"
  health_check_id = aws_route53_health_check.tokyo_health.id
  ttl             = "60"
  records         = [aws_instance.tokyo_web.public_ip]
}

# osaka record (secondary)
resource "aws_route53_record" "portfolio_secondary" {
  zone_id = aws_route53_zone.portfolio_sub.zone_id
  name    = "portfolio.vexations.org"
  type    = "A"

# failover stuff
  failover_routing_policy {
    type = "SECONDARY"
  }

  set_identifier = "osaka"
  ttl            = "60"
  records        = [aws_instance.osaka_web.public_ip]
}