# Terraform AWS OpenClaw

A Terraform module to deploy [OpenClaw](https://github.com/openclaw/openclaw) on AWS EC2 with Tailscale integration. This module provisions a complete infrastructure including VPC, subnet, security groups, and an EC2 instance configured with OpenClaw, Docker, and Tailscale for secure remote access.

## Features

- 🚀 Automated deployment of OpenClaw on Ubuntu 24.04 LTS
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
- [Anthropic API key](https://console.anthropic.com/)
- [Tailscale account](https://tailscale.com/) and auth key

## Usage

### Basic Example

```hcl
module "openclaw" {
  source = "github.com/srajasimman/terraform-aws-openclaw"

  region             = "us-east-1"
  instance_type      = "t3.medium"
  anthropic_api_key  = var.anthropic_api_key
  tailscale_auth_key = var.tailscale_auth_key
  tailnet_dns_name   = "your-tailnet.ts.net"
}
```

### Complete Example

See [examples/complete](./examples/complete) for a full working example.

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| region | AWS region to deploy resources | `string` | `"us-east-1"` | no |
| instance_type | EC2 instance type | `string` | `"t3.medium"` | no |
| anthropic_api_key | Anthropic API key for OpenClaw | `string` | n/a | yes |
| tailscale_auth_key | Tailscale authentication key | `string` | n/a | yes |
| tailnet_dns_name | Tailscale network DNS name (e.g., your-tailnet.ts.net) | `string` | n/a | yes |
| gateway_port | Port for OpenClaw gateway | `number` | `18789` | no |
| browser_port | Port for browser access | `number` | `18791` | no |

## Outputs

| Name | Description |
|------|-------------|
| public_ip | Public IP address of the EC2 instance |
| public_dns | Public DNS name of the EC2 instance |
| ssh_private_key | SSH private key (sensitive) |
| gateway_token | Auto-generated gateway authentication token (sensitive) |
| tailscale_url_with_token | Tailscale URL with embedded gateway token |
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
