# Complete Example: OpenClaw on AWS

This example demonstrates a complete deployment of OpenClaw on AWS EC2 with all features configured.

## Prerequisites

1. **LLM Provider API Key** (choose one):
   - **Anthropic**: Get from [Anthropic Console](https://console.anthropic.com/) (default)
   - **OpenRouter**: Get from [OpenRouter](https://openrouter.ai/keys)
   - **OpenAI**: Get from [OpenAI Platform](https://platform.openai.com/api-keys)
   - **OpenCode Zen**: Get from your OpenCode Zen account
2. **Tailscale Account**: Sign up at [Tailscale](https://tailscale.com/)
3. **Tailscale Auth Key**: Generate from [Tailscale Admin](https://login.tailscale.com/admin/settings/keys)
   - Recommended: Create a reusable key with appropriate expiration
4. **Tailnet DNS Name**: Find in your Tailscale admin console (e.g., `your-tailnet.ts.net`)

## Quick Start

1. **Copy the example configuration:**
   ```bash
   cd examples/complete
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit terraform.tfvars with your values:**
   ```bash
   vim terraform.tfvars
   ```

3. **Initialize Terraform:**
   ```bash
   terraform init
   ```

4. **Plan the deployment:**
   ```bash
   terraform plan
   ```

5. **Apply the configuration:**
   ```bash
   terraform apply
   ```

6. **Access OpenClaw:**
   ```bash
   # Get the Tailscale URL with embedded token
   terraform output -raw tailscale_access_url
   
   # Or get just the gateway token
   terraform output -raw gateway_token
   ```

## Configuration

### Required Variables

All required variables must be set in `terraform.tfvars`:

```hcl
# LLM Provider - choose one of: anthropic, openrouter, openai, opencode-zen
llm_provider = "anthropic"  # Default

# API Key for your chosen provider (only one required)
anthropic_api_key  = "sk-ant-api03-..."  # If using Anthropic
# openrouter_api_key = "sk-or-v1-..."    # If using OpenRouter
# openai_api_key     = "sk-..."          # If using OpenAI
# opencode_zen_api_key = "sk-..."        # If using OpenCode Zen

# Tailscale configuration (always required)
tailscale_auth_key = "tskey-auth-..."     # From Tailscale Admin
tailnet_dns_name   = "your-tailnet.ts.net" # Your Tailscale network
```

### Optional Variables

Customize the deployment with optional variables:

```hcl
region        = "us-east-1"  # Default AWS region
instance_type = "t3.medium"  # Default instance type
gateway_port  = 18789        # OpenClaw gateway port
browser_port  = 18791        # Browser access port
```

## What Gets Deployed

- **VPC** (10.0.0.0/16) with DNS enabled
- **Internet Gateway** for public access
- **Public Subnet** (10.0.1.0/24)
- **Route Table** with internet route
- **Security Group** allowing SSH (port 22) and all egress
- **EC2 Instance** (t3.medium) with:
  - Ubuntu 24.04 LTS
  - Docker
  - Node.js 22 (via NVM)
  - OpenClaw CLI
  - Tailscale

## Post-Deployment

### Access the UI

```bash
# Get the access URL with token
terraform output -raw tailscale_access_url

# Example output:
# https://ip-10-0-1-123.your-tailnet.ts.net/?token=abc123...
```

### SSH into the Instance

```bash
# Save the SSH key
terraform output -raw ssh_private_key > openclaw-key.pem
chmod 600 openclaw-key.pem

# Connect via SSH
ssh -i openclaw-key.pem ubuntu@$(terraform output -raw instance_public_ip)
```

### Verify Installation

```bash
# SSH into the instance
ssh -i openclaw-key.pem ubuntu@$(terraform output -raw instance_public_ip)

# Check OpenClaw
source ~/.nvm/nvm.sh
openclaw --version

# Check Docker
docker --version

# Check Tailscale
sudo tailscale status

# View installation logs
sudo tail -100 /var/log/cloud-init-output.log
```

## Outputs

This example provides helpful outputs:

| Output | Description |
|--------|-------------|
| `instance_public_ip` | Public IP of the EC2 instance |
| `instance_public_dns` | Public DNS name |
| `ssh_command` | Full SSH command to connect |
| `ssh_private_key` | SSH private key (sensitive) |
| `gateway_token` | Gateway auth token (sensitive) |
| `tailscale_access_url` | Full URL to access OpenClaw |
| `instructions` | Post-deployment guide |

## Customization Examples

### Use Different LLM Provider

```hcl
# terraform.tfvars
llm_provider       = "openai"
openai_api_key     = "sk-..."
```

### Deploy in Different Region

```hcl
# terraform.tfvars
region = "eu-west-1"
```

### Use Larger Instance

```hcl
# terraform.tfvars
instance_type = "t3.large"
```

### Custom Ports

```hcl
# terraform.tfvars
gateway_port = 19000
browser_port = 19001
```

## Cost Estimation

Approximate monthly costs (us-east-1):

- **EC2 t3.medium**: ~$30.37/month
- **EBS gp3 30GB**: ~$2.40/month
- **Network**: Minimal (within free tier for typical usage)

**Total**: ~$33/month

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

## Troubleshooting

### Check User Data Logs

```bash
ssh -i openclaw-key.pem ubuntu@$(terraform output -raw instance_public_ip)
sudo tail -f /var/log/cloud-init-output.log
```

### Verify Tailscale Connection

```bash
sudo tailscale status
sudo tailscale serve status
```

### Check OpenClaw Status

```bash
source ~/.nvm/nvm.sh
systemctl --user status openclaw-daemon
journalctl --user -u openclaw-daemon -f
```

### Instance Not Reachable

- Verify security group allows SSH from your IP
- Check instance is in running state
- Ensure instance has public IP

## Additional Resources

- [OpenClaw Documentation](https://github.com/anthropics/openclaw)
- [Anthropic API Docs](https://docs.anthropic.com/)
- [Tailscale Setup Guide](https://tailscale.com/kb/)
