variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region to deploy resources"
}

variable "instance_type" {
  type        = string
  default     = "t3.medium"
  description = "EC2 instance type"
}

variable "llm_provider" {
  type        = string
  default     = "anthropic"
  description = "LLM provider to use with OpenClaw (anthropic, openrouter, openai, or opencode-zen)"

  validation {
    condition     = contains(["anthropic", "openrouter", "openai", "opencode-zen"], var.llm_provider)
    error_message = "llm_provider must be one of: 'anthropic', 'openrouter', 'openai', or 'opencode-zen'"
  }
}

variable "anthropic_api_key" {
  type        = string
  default     = ""
  sensitive   = true
  description = "Anthropic API key (required when llm_provider is 'anthropic')"
}

variable "openrouter_api_key" {
  type        = string
  default     = ""
  sensitive   = true
  description = "OpenRouter API key (required when llm_provider is 'openrouter')"
}

variable "openai_api_key" {
  type        = string
  default     = ""
  sensitive   = true
  description = "OpenAI API key (required when llm_provider is 'openai')"
}

variable "opencode_zen_api_key" {
  type        = string
  default     = ""
  sensitive   = true
  description = "OpenCode Zen API key (required when llm_provider is 'opencode-zen')"
}

variable "tailscale_auth_key" {
  type        = string
  sensitive   = true
  description = "Tailscale authentication key (reusable, ephemeral recommended)"
}

variable "tailnet_dns_name" {
  type        = string
  description = "Tailnet DNS name (e.g., example.ts.net)"
}

variable "gateway_port" {
  type        = number
  default     = 18789
  description = "Port for the OpenClaw gateway service"
}

variable "browser_port" {
  type        = number
  default     = 18791
  description = "Port for the OpenClaw browser service"
}
