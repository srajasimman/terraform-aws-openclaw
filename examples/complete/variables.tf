variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"

  validation {
    condition     = can(regex("^t[2-3]\\.(nano|micro|small|medium|large|xlarge|2xlarge)$", var.instance_type))
    error_message = "Instance type must be a valid t2 or t3 instance type."
  }
}

variable "anthropic_api_key" {
  description = "Anthropic API key for OpenClaw (get from https://console.anthropic.com/)"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.anthropic_api_key) > 0
    error_message = "Anthropic API key cannot be empty."
  }
}

variable "tailscale_auth_key" {
  description = "Tailscale authentication key (generate from https://login.tailscale.com/admin/settings/keys)"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.tailscale_auth_key) > 0
    error_message = "Tailscale auth key cannot be empty."
  }
}

variable "tailnet_dns_name" {
  description = "Your Tailscale network DNS name (e.g., your-tailnet.ts.net)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+\\.ts\\.net$", var.tailnet_dns_name))
    error_message = "Tailnet DNS name must be in the format: your-tailnet.ts.net"
  }
}

variable "gateway_port" {
  description = "Port for OpenClaw gateway"
  type        = number
  default     = 18789

  validation {
    condition     = var.gateway_port >= 1024 && var.gateway_port <= 65535
    error_message = "Gateway port must be between 1024 and 65535."
  }
}

variable "browser_port" {
  description = "Port for browser access"
  type        = number
  default     = 18791

  validation {
    condition     = var.browser_port >= 1024 && var.browser_port <= 65535
    error_message = "Browser port must be between 1024 and 65535."
  }
}
