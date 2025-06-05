output "ec2_public_ip" {
  description = "デプロイされたEC2のパブリックIP"
  value       = aws_instance.demo_ec2.public_ip
}
