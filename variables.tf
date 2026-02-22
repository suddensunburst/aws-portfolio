variable "cloudflare_api_token" {
  description = "Cloudflare API Token"
  type        = string
  sensitive   = true # suppress logs
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
}