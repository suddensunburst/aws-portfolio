# dns: make "portfolio" subdomain zone
resource "aws_route53_zone" "portfolio_sub" {
  name = "portfolio.${var.main_domain}"
}

# tokyo record (primary)
resource "aws_route53_record" "portfolio_primary" {
  zone_id = aws_route53_zone.portfolio_sub.zone_id
  name    = "portfolio.${var.main_domain}"
  type    = "A"

# use an alias when using alb (free and fast)
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
}

# osaka record (secondary)
resource "aws_route53_record" "osaka_failover" {
  zone_id = aws_route53_zone.portfolio_sub.zone_id
  name    = "portfolio.${var.main_domain}"
  type    = "A"

  # specify alb as an alias
  alias {
    name                   = aws_lb.osaka_alb.dns_name
    zone_id                = aws_lb.osaka_alb.zone_id
    evaluate_target_health = true
  }

  # failover stuff
  failover_routing_policy {
    type = "SECONDARY"
  }

  set_identifier = "osaka"
}

# add 4 records which route 53 sent (might wanna try some toset stuff...)
resource "cloudflare_record" "portfolio_ns" {
  count   = 4
  zone_id = var.cloudflare_zone_id
  name    = "portfolio"
  content   = aws_route53_zone.portfolio_sub.name_servers[count.index]
  type    = "NS"
  ttl     = 60
}