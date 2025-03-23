#  to hold variable declration which are meant to be retrieved back after applyibg terraform code
output "jenkins_public_ip" {
    description = "Public IP of jenkins instance"
    value = aws_instance.Jenkins.public_ip 
}
output "sonarqube_public_ip" {
    description = "Public IP of sonarqube instance"
    value = aws_instance.sonarqube.public_ip 
}
output "ansible_public_ip" {
    description = "Public IP of Ansible instance"
    value = aws_instance.ansible.public_ip 
}