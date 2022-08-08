output "webapp_public_ip" {
  value = aws_instance.webapp.public_ip
}

output "webapp_private_ip" {
  value = aws_instance.webapp.private_ip
}

output "mongodb_public_ip" {
  value = aws_instance.mongodb.public_ip
}

output "mongodb_private_ip" {
  value = aws_instance.mongodb.private_ip
}
output "webapp-key" {
  value = file("~/.ssh/webapp-key.pem")
}