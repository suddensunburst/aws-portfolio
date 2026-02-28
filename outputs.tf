# show ns
output "portfolio_ns" {
  value = aws_route53_zone.portfolio_sub.name_servers
}

# show the public ip of tokyo instance
output "tokyo_web_public_ip" {
  value = "http://${aws_instance.tokyo_web_1a.public_ip}"
}

# show the public ip of oskaka instance
output "osaka_web_public_ip" {
  value = "http://${aws_instance.osaka_web_3a.public_ip}"

}

