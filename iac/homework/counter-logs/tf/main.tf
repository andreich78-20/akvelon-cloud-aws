output "app_instance" {
  value = aws_instance.lab-counter-web-server.public_dns
}
