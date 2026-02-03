output "instance_public_ip" {
  description = "Public IP address of the OpenClaw EC2 instance"
  value       = module.openclaw.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the OpenClaw EC2 instance"
  value       = module.openclaw.public_dns
}

output "ssh_command" {
  description = "SSH command to connect to the instance (save private key first)"
  value       = "terraform output -raw ssh_private_key > openclaw-key.pem && chmod 600 openclaw-key.pem && ssh -i openclaw-key.pem ubuntu@${module.openclaw.public_ip}"
}

output "ssh_private_key" {
  description = "SSH private key for connecting to the instance"
  value       = module.openclaw.ssh_private_key
  sensitive   = true
}

output "gateway_token" {
  description = "Auto-generated gateway authentication token"
  value       = module.openclaw.gateway_token
  sensitive   = true
}

output "tailscale_access_url" {
  description = "Tailscale URL to access OpenClaw (includes auth token)"
  value       = module.openclaw.tailscale_url_with_token
  sensitive   = true
}

output "instructions" {
  description = "Post-deployment instructions"
  value       = <<-EOT

    ========================================
    OpenClaw Deployment Complete!
    ========================================

    Next Steps:

    1. Get your gateway token:
       terraform output -raw gateway_token

    2. Access OpenClaw via Tailscale:
       terraform output -raw tailscale_access_url

       Copy this URL and open it in your browser.

    3. (Optional) SSH into the instance:
       terraform output -raw ssh_private_key > openclaw-key.pem
       chmod 600 openclaw-key.pem
       ssh -i openclaw-key.pem ubuntu@${module.openclaw.public_ip}

    4. Check logs if needed:
       ssh -i openclaw-key.pem ubuntu@${module.openclaw.public_ip}
       sudo tail -f /var/log/cloud-init-output.log

    Resources:
    - Instance IP: ${module.openclaw.public_ip}
    - Instance DNS: ${module.openclaw.public_dns}
    - Region: ${var.region}
    - Instance Type: ${var.instance_type}

    ========================================
  EOT
}
