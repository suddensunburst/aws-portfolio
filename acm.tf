# 1. requesting cert
resource "aws_acm_certificate" "cert" {
  domain_name       = "portfolio.${var.main_domain}"
  validation_method = "DNS"

  tags = { Name = "portfolio-cert" }

  lifecycle {
    create_before_destroy = true
  }
}

# 2. create CNAME on route 53
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.portfolio_sub.zone_id
}

# 3. wait until the validation process completes (otherwise alb fails or so they say)
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}