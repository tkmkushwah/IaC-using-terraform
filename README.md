# IaC-using-terraform

AWS Infrastructure Setup Using Terraform

Project Overview

This project sets up a secure and scalable AWS infrastructure using Terraform. It provisions a Virtual Private Cloud (VPC) along with subnets, security groups, routing tables, and essential networking components to host applications like Jenkins, SonarQube, Grafana, and more. Additionally, it includes an AWS Elastic Container Registry (ECR) and an S3 bucket for Terraform state management.

Infrastructure Components

1. VPC (Virtual Private Cloud)

A VPC named Production VPC is created with a CIDR block defined by var.vpc_cidr.

The VPC provides a logically isolated network environment for cloud resources.

2. Subnets

Public and private subnets are created in the us-east-1b availability zone.

Public subnets (public_subnet1 and public_subnet2) are configured to auto-assign public IPs.

A private subnet is provisioned for internal resources.

3. Internet Gateway & NAT Gateway

An Internet Gateway (IGW) is attached to the VPC to enable internet access for public subnets.

A NAT Gateway is provisioned to allow outbound internet access for private subnets.

An Elastic IP (EIP) is allocated and associated with the NAT Gateway.

4. Route Tables

A public route table directs traffic to the Internet Gateway for internet access.

A private route table routes outbound traffic via the NAT Gateway.

Public subnets are associated with the public route table, while private subnets use the private route table.

5. Security Groups

Security groups are configured for various services to control inbound and outbound traffic:

Service

Allowed Ports

Description

Jenkins

8080, 22

Allows access to Jenkins UI and SSH

SonarQube

9000, 22

Allows access to SonarQube UI and SSH

Grafana

3000, 22

Allows access to Grafana UI and SSH

Ansible

22

Allows SSH access

Application

80, 22

Allows HTTP and SSH access

Load Balancer

80

Allows HTTP access

6. Network ACLs (NACLs)

An ACL is created to manage inbound and outbound traffic at the subnet level.

Allows HTTP, SSH, Jenkins, SonarQube, and Grafana traffic from external sources.

7. Elastic Container Registry (ECR)

A private ECR repository named docker repository is created for storing container images.

Image scanning is enabled for security compliance.

8. Key Pair

An SSH key pair is created to allow secure access to EC2 instances.

9. S3 Bucket for Terraform State Management

An S3 bucket named devops-project-terraform-state is created to store Terraform state files securely.

Versioning is enabled for state file integrity and backup.

10. Terraform Backend Configuration

Terraform backend is configured to use the S3 bucket for remote state storage.

The state file is stored at prod/terraform.tfstate in the S3 bucket.

How to Deploy

Initialize Terraform

terraform init

Validate Configuration

terraform validate

Plan the Infrastructure Deployment

terraform plan

Apply the Configuration

terraform apply -auto-approve

Destroy the Infrastructure (if needed)

terraform destroy -auto-approve

Conclusion

This Terraform script provisions a production-ready AWS environment with best practices for networking, security, and DevOps tools. It enables secure, scalable, and efficient deployment of applications in the cloud.