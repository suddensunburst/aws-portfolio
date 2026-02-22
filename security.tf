# tokyo security group
resource "aws_security_group" "tokyo_web_sg" {
  name   = "portfolio-web-sg"
  vpc_id = aws_vpc.main.id

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
  provider = aws.osaka
  name     = "portfolio-osaka-web-sg"
  vpc_id   = aws_vpc.osaka_main.id

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

# tokyo alb security group
resource "aws_security_group" "tokyo_alb_sg" {
  name   = "portfolio-alb-sg"
  vpc_id = aws_vpc.main.id

  # allow http
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow all egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "portfolio-alb-sg" }
}
