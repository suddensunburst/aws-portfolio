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

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
}



# osaka latest amazon linux 2023 id
data "aws_ssm_parameter" "osaka_amzn2023_ami" {
  provider = aws.osaka
  name     = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

# launch osaka web server
resource "aws_instance" "osaka_web" {
  provider      = aws.osaka
  ami           = data.aws_ssm_parameter.osaka_amzn2023_ami.value
  instance_type = "t3.micro"

  # force public ip
  associate_public_ip_address = true

  # subnet 1a
  subnet_id = aws_subnet.osaka_public_3a.id

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

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
}

