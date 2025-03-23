#  to hold variable declration which are meant to be retrieved back after applyibg terraform code
output "jenkins_public_ip" {
    description = "Public IP of jenkins instance"
    value = aws_instance.Jenkins.public_ip 
}