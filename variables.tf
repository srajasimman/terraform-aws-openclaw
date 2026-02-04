variable "region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
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
