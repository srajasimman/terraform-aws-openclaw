# Agent Guidelines for terraform-aws-openclaw

Terraform module deploying OpenClaw on AWS EC2 with Tailscale integration.

## Build, Lint, and Test Commands

### Format & Validate
```bash
terraform fmt -recursive              # Auto-format all files
terraform fmt -check -recursive       # Check formatting (CI)

terraform init -backend=false         # Initialize without backend
terraform validate                    # Validate configuration

cd examples/complete && terraform init -backend=false && terraform validate  # Validate example
```

### Security & Documentation
```bash
tfsec .                              # Security scan
terraform-docs markdown table --output-file README.md --output-mode inject .  # Update docs
```

### Testing (Plan Only)
```bash
# Test root module
terraform init
terraform plan -var="anthropic_api_key=test" -var="tailscale_auth_key=test" -var="tailnet_dns_name=example.ts.net"

# Test example
cd examples/complete && terraform plan -var-file=terraform.tfvars.example
```

## Code Style Guidelines

### File Structure
- **main.tf**: Providers, data sources, locals, resources (ordered: keys → networking → security → compute)
- **variables.tf**: Input variables with types, defaults, descriptions
- **outputs.tf**: Output values with sensitivity markers
- **userdata.sh.tftpl**: User data templates
- **examples/**: Usage examples

### Formatting (.editorconfig)
- UTF-8 charset, LF line endings
- 2-space indentation (no tabs)
- 80-character line limit
- Remove trailing whitespace, require final newline

### Naming Conventions
```hcl
# Resources: Use "this" for single resources, descriptive names with underscores
resource "aws_vpc" "this" { }                    # ✓ Good
resource "aws_vpc" "vpc1" { }                    # ✗ Avoid

# Variables: Descriptive snake_case with type and sensitivity
variable "anthropic_api_key" {
  type      = string
  sensitive = true
  description = "Anthropic API key"              # Always include description
}

# Locals: Computed values
locals {
  gateway_token = substr(sha256(tls_private_key.gateway.public_key_openssh), 0, 48)
}

# Outputs: Mark sensitive data
output "gateway_token" {
  value     = local.gateway_token
  sensitive = true
}
```

### Resource Formatting
```hcl
# Align arguments, group logically, use inline tags for simple cases
resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "openclaw-vpc" }
}
```

### Template Files
```hcl
# Use .tftpl extension, reference with path.module
user_data = templatefile("${path.module}/userdata.sh.tftpl", {
  anthropic_api_key  = var.anthropic_api_key
  gateway_token      = local.gateway_token
})
```

### Bash Scripts (userdata)
```bash
#!/bin/bash
set -euo pipefail                    # Fail fast, catch errors
export DEBIAN_FRONTEND=noninteractive

# Make idempotent with state files
if [ ! -f "$STATE_DIR/installed" ]; then
  log "Installing..."
  # installation steps
  touch "$STATE_DIR/installed"
else
  log "Already installed"
fi
```

## Security Requirements

- Mark all secrets: `sensitive = true` on variables and outputs
- Never commit: `.terraform/`, `*.tfstate`, `*.tfvars` (except `.example`)
- Use `tls_private_key` for key generation
- Document security considerations in README
- Validate with tfsec before committing

## Version Constraints

```hcl
terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
    tls = { source = "hashicorp/tls", version = "~> 4.0" }
  }
}
```

## Common Patterns

```hcl
# String replacement in outputs
value = "https://ip-${replace(aws_instance.this.private_ip, ".", "-")}.${var.tailnet_dns_name}"

# Conditional resources
count = var.create_resource ? 1 : 0

# Module path references
templatefile("${path.module}/template.tftpl", { var = value })
```

## CI/CD (GitHub Actions)

Three jobs run on push/PR:
- **validate**: `terraform fmt -check`, `init`, `validate`
- **security**: `tfsec` security scan
- **documentation**: Auto-update README with terraform-docs

## Documentation Standards

- Use terraform-docs with `<!-- BEGIN_TF_DOCS -->` / `<!-- END_TF_DOCS -->` markers
- Document all variables with descriptions
- Include examples in `examples/` directory
- Add inline comments for complex logic only
- Reference code as `filename:line_number` (e.g., `main.tf:119`)

## Contribution Workflow

1. Make changes following style guidelines
2. Run `terraform fmt -recursive`
3. Run `terraform validate` (root + examples)
4. Run `terraform-docs` if variables/outputs changed
5. Test with `terraform plan`
6. Ensure all CI checks pass
7. Commit with clear, descriptive messages
