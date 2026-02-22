# dns: make "portfolio" subdomain zone
resource "aws_route53_zone" "portfolio_sub" {
  name = "portfolio.${var.main_domain}"
}

# tokyo health check (there has to be a better way)
resource "aws_route53_health_check" "tokyo_health" {
  ip_address        = aws_instance.tokyo_web_1a.public_ip
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = "3" # three strikes
  request_interval  = "10"

  tags = { Name = "tokyo-health-check" }
}

# tokyo record (primary)
resource "aws_route53_record" "portfolio_primary" {
  zone_id = aws_route53_zone.portfolio_sub.zone_id
  name    = "portfolio.${var.main_domain}"
  type    = "A"

# use alias when using alb (free and fast)
  alias {
    name                   = aws_lb.tokyo_alb.dns_name
    zone_id                = aws_lb.tokyo_alb.zone_id
    evaluate_target_health = true
  }

  # failover stuff
  failover_routing_policy {
    type = "PRIMARY"
  }

  set_identifier  = "tokyo"
  health_check_id = aws_route53_health_check.tokyo_health.id
}

# osaka record (secondary)
resource "aws_route53_record" "portfolio_secondary" {
  zone_id = aws_route53_zone.portfolio_sub.zone_id
  name    = "portfolio.${var.main_domain}"
  type    = "A"

  # failover stuff
  failover_routing_policy {
    type = "SECONDARY"
  }

  set_identifier = "osaka"
  ttl            = "60"
  records        = [aws_instance.osaka_web.public_ip]
}

# add 4 records route 53 sent (might wanna try some toset stuff...)
resource "cloudflare_record" "portfolio_ns" {
  count   = 4
  zone_id = var.cloudflare_zone_id
  name    = "portfolio"
  content   = aws_route53_zone.portfolio_sub.name_servers[count.index]
  type    = "NS"
  ttl     = 60
}