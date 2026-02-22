# ALB
resource "aws_lb" "tokyo_alb" {
  name               = "portfolio-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.tokyo_alb_sg.id]
  subnets            = [aws_subnet.public_1a.id, aws_subnet.public_1c.id]
}

# target group
resource "aws_lb_target_group" "tokyo_tg" {
  name     = "portfolio-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 15 # should be faster than route 53 one
    unhealthy_threshold = 2
  }
}

# listener
resource "aws_lb_listener" "tokyo_http" {
  load_balancer_arn = aws_lb.tokyo_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tokyo_tg.arn
  }
}

# attach to tokyo web instances
resource "aws_lb_target_group_attachment" "tokyo_1a" {
  target_group_arn = aws_lb_target_group.tokyo_tg.arn
  target_id        = aws_instance.tokyo_web_1a.id
}

resource "aws_lb_target_group_attachment" "tokyo_1c" {
  target_group_arn = aws_lb_target_group.tokyo_tg.arn
  target_id        = aws_instance.tokyo_web_1c.id
}