output "public_ip" {
  value       = aws_instance.this.public_ip
  description = "Public IP address of the EC2 instance"
}

output "public_dns" {
  value       = aws_instance.this.public_dns
  description = "Public DNS name of the EC2 instance"
}

output "ssh_private_key" {
  value       = tls_private_key.ssh.private_key_openssh
  sensitive   = true
  description = "Private SSH key for accessing the instance"
}

output "gateway_token" {
  value       = local.gateway_token
  sensitive   = true
  description = "Authentication token for the OpenClaw gateway"
}

output "tailscale_url_with_token" {
  value       = "https://ip-${replace(aws_instance.this.private_ip, ".", "-")}.${var.tailnet_dns_name}/?token=${local.gateway_token}"
  description = "Full URL to access OpenClaw via Tailscale with token included"
}
