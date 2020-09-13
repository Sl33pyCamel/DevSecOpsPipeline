output "jenkins_ip_address" {
  value = "http://${aws_instance.jenkinsmaster.public_dns}:8080"
}
