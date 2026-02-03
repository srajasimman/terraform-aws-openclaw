variable "region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "anthropic_api_key" {
  type      = string
  sensitive = true
}

variable "tailscale_auth_key" {
  type      = string
  sensitive = true
}

variable "tailnet_dns_name" {
  type = string
}

variable "gateway_port" {
  type    = number
  default = 18789
}

variable "browser_port" {
  type    = number
  default = 18791
}
