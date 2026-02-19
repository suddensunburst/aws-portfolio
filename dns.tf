# dns: make "portfolio" subdomain zone
resource "aws_route53_zone" "portfolio_sub" {
  name = "portfolio.vexations.org"
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