# Terraform AWS OpenClaw

A Terraform module to deploy [OpenClaw](https://github.com/openclaw/openclaw) on AWS EC2 with Tailscale integration. This module provisions a complete infrastructure including VPC, subnet, security groups, and an EC2 instance configured with OpenClaw, Docker, and Tailscale for secure remote access.

## Features

- 🚀 Automated deployment of OpenClaw on Ubuntu 24.04 LTS
- 🤖 **Multi-provider LLM support**: Anthropic, OpenRouter, OpenAI, and OpenCode Zen
- 🔐 Tailscale integration for secure remote access
- 🐳 Docker pre-installed for container-based skills
- 🔑 Automatic SSH key pair generation
- 🌐 Complete VPC and networking setup
- 🛡️ Gateway authentication with auto-generated tokens
- ⚡ Idempotent user data script for safe re-runs

## Architecture

This module deploys:

- **VPC** with DNS support enabled
- **Internet Gateway** for public connectivity
- **Public Subnet** with auto-assigned public IPs
- **Security Group** allowing SSH and egress traffic
- **EC2 Instance** (t3.medium by default) running:
  - Ubuntu 24.04 LTS
  - Docker
  - Node.js (via NVM)
  - OpenClaw
  - Tailscale

## Prerequisites

- Terraform >= 1.5
- AWS credentials configured
- **LLM Provider API Key** (choose one):
  - [Anthropic API key](https://console.anthropic.com/) (default)
  - [OpenRouter API key](https://openrouter.ai/keys)
  - [OpenAI API key](https://platform.openai.com/api-keys)
  - OpenCode Zen API key
- [Tailscale account](https://tailscale.com/) and auth key

## Usage

### Basic Example

```hcl
module "openclaw" {
  source = "github.com/srajasimman/terraform-aws-openclaw"

  region             = "us-east-1"
  instance_type      = "t3.medium"
  
  # LLM Provider (default: anthropic)
  llm_provider       = "anthropic"
  anthropic_api_key  = var.anthropic_api_key
  
  tailscale_auth_key = var.tailscale_auth_key
  tailnet_dns_name   = "your-tailnet.ts.net"
}
```

### Using Different LLM Providers

**OpenRouter:**
```hcl
module "openclaw" {
  source = "github.com/srajasimman/terraform-aws-openclaw"

  llm_provider       = "openrouter"
  openrouter_api_key = var.openrouter_api_key
  # ... other required variables
}
```

**OpenAI:**
```hcl
module "openclaw" {
  source = "github.com/srajasimman/terraform-aws-openclaw"

  llm_provider    = "openai"
  openai_api_key  = var.openai_api_key
  # ... other required variables
}
```

**OpenCode Zen:**
```hcl
module "openclaw" {
  source = "github.com/srajasimman/terraform-aws-openclaw"

  llm_provider         = "opencode-zen"
  opencode_zen_api_key = var.opencode_zen_api_key
  # ... other required variables
}
```

### Complete Example

See [examples/complete](./examples/complete) for a full working example.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | ~> 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_key_pair.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_route_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [tls_private_key.gateway](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_private_key.ssh](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_anthropic_api_key"></a> [anthropic\_api\_key](#input\_anthropic\_api\_key) | Anthropic API key (required when llm\_provider is 'anthropic') | `string` | `""` | no |
| <a name="input_browser_port"></a> [browser\_port](#input\_browser\_port) | n/a | `number` | `18791` | no |
| <a name="input_gateway_port"></a> [gateway\_port](#input\_gateway\_port) | n/a | `number` | `18789` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | n/a | `string` | `"t3.medium"` | no |
| <a name="input_llm_provider"></a> [llm\_provider](#input\_llm\_provider) | LLM provider to use with OpenClaw (anthropic, openrouter, openai, or opencode-zen) | `string` | `"anthropic"` | no |
| <a name="input_openai_api_key"></a> [openai\_api\_key](#input\_openai\_api\_key) | OpenAI API key (required when llm\_provider is 'openai') | `string` | `""` | no |
| <a name="input_opencode_zen_api_key"></a> [opencode\_zen\_api\_key](#input\_opencode\_zen\_api\_key) | OpenCode Zen API key (required when llm\_provider is 'opencode-zen') | `string` | `""` | no |
| <a name="input_openrouter_api_key"></a> [openrouter\_api\_key](#input\_openrouter\_api\_key) | OpenRouter API key (required when llm\_provider is 'openrouter') | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"us-east-1"` | no |
| <a name="input_tailnet_dns_name"></a> [tailnet\_dns\_name](#input\_tailnet\_dns\_name) | n/a | `string` | n/a | yes |
| <a name="input_tailscale_auth_key"></a> [tailscale\_auth\_key](#input\_tailscale\_auth\_key) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gateway_token"></a> [gateway\_token](#output\_gateway\_token) | n/a |
| <a name="output_public_dns"></a> [public\_dns](#output\_public\_dns) | n/a |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | n/a |
| <a name="output_ssh_private_key"></a> [ssh\_private\_key](#output\_ssh\_private\_key) | n/a |
| <a name="output_tailscale_url_with_token"></a> [tailscale\_url\_with\_token](#output\_tailscale\_url\_with\_token) | n/a |
<!-- END_TF_DOCS -->

## Accessing OpenClaw

After deployment:

1. **Retrieve the gateway token:**
   ```bash
   terraform output -raw gateway_token
   ```

2. **Access via Tailscale:**
   ```bash
   terraform output tailscale_url_with_token
   ```
   
   Open this URL in your browser to access the OpenClaw control UI.

3. **SSH access (optional):**
   ```bash
   terraform output -raw ssh_private_key > openclaw-key.pem
   chmod 600 openclaw-key.pem
   ssh -i openclaw-key.pem ubuntu@$(terraform output -raw public_ip)
   ```

## How It Works

1. **Infrastructure Provisioning**: Creates VPC, subnet, internet gateway, security groups, and EC2 instance
2. **SSH Keys**: Generates ED25519 SSH key pairs for instance access
3. **Gateway Token**: Derives a secure token from the gateway key pair
4. **User Data**: Installs and configures:
   - Docker
   - Node.js via NVM
   - OpenClaw CLI
   - Tailscale
5. **OpenClaw Setup**: Onboards OpenClaw with API key authentication and local mode
6. **Tailscale Integration**: Configures Tailscale serve to expose the gateway securely

## Security Considerations

- 🔐 Gateway token is automatically generated and marked as sensitive
- 🔑 SSH private key is marked as sensitive in outputs
- 🌐 OpenClaw gateway is exposed only via Tailscale (loopback binding)
- ⚠️ SSH port 22 is open to 0.0.0.0/0 (consider restricting in production)
- 🛡️ All sensitive variables (API keys, auth keys) are marked as sensitive

## Customization

### Change Instance Type

```hcl
module "openclaw" {
  source = "github.com/srajasimman/terraform-aws-openclaw"
  
  instance_type = "t3.large"  # More resources for complex tasks
  # ... other variables
}
```

### Different Region

```hcl
module "openclaw" {
  source = "github.com/srajasimman/terraform-aws-openclaw"
  
  region = "eu-west-1"  # Deploy in Europe
  # ... other variables
}
```

## Troubleshooting

### Check User Data Execution

```bash
ssh -i openclaw-key.pem ubuntu@$(terraform output -raw public_ip)
sudo tail -f /var/log/cloud-init-output.log
```

### Verify OpenClaw Installation

```bash
ssh -i openclaw-key.pem ubuntu@$(terraform output -raw public_ip)
source ~/.nvm/nvm.sh
openclaw --version
```

### Check Tailscale Status

```bash
ssh -i openclaw-key.pem ubuntu@$(terraform output -raw public_ip)
sudo tailscale status
```

## Cost Estimation

Approximate monthly costs (us-east-1):

- EC2 t3.medium: ~$30/month
- EBS gp3 30GB: ~$2.40/month
- Data transfer: Variable
- **Total: ~$32-35/month** (excluding data transfer)

## License

See [LICENSE](./LICENSE) file for details.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## References

- [OpenClaw Documentation](https://docs.openclaw.ai/)
- [Anthropic API](https://docs.anthropic.com/)
- [Tailscale](https://tailscale.com/kb/)
