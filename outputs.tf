output "public_ip" {
  value = aws_instance.this.public_ip
}

output "public_dns" {
  value = aws_instance.this.public_dns
}

output "ssh_private_key" {
  value     = tls_private_key.ssh.private_key_openssh
  sensitive = true
}

output "gateway_token" {
  value     = local.gateway_token
  sensitive = true
}

output "tailscale_url_with_token" {
  value = "https://ip-${replace(aws_instance.this.private_ip, ".", "-")}.${var.tailnet_dns_name}/?token=${local.gateway_token}"
}
