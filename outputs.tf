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

