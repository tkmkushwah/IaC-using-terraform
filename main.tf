# initiate the provider
/*
provider "aws"{
     region =var.region
     
 } # we will provide these credentials as env var.
*/
# create the VPC
resource "aws_vpc" "production_vpc" {
  cidr_block =var.vpc_cidr
  tags = {
    Name = "Production VPC"
  }
}
# create internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.production_vpc.id
  
}

# create elastic ip to associte with NAT gateway
# NAT Gateway requires an Elastic IP for outbound internet access from private subnets.
# AWS does not assign public IPs to NAT Gateways automatically.
resource "aws_eip" "nat_eip" {
  depends_on = [ aws_internet_gateway.igw ]  //ensures the IGW exists before creating the EIP.
}

# create the nat gateway
# Private subnets do not have direct internet access.
# Using a NAT Gateway allows updates/downloads securely.
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.public_subnet1.id
  tags = {
    Name ="NAT Gateway" 
  }

}

#create public route table 
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.production_vpc.id //where we want to create route table
  route {
    cidr_block = var.all_cidr        // Routes all outgoing traffic (0.0.0.0/0) via the Internet Gateway (IGW).
    gateway_id = aws_internet_gateway.igw.id 
  }
  tags = {
    Name="Public RT"
  }

}
#create public route table 
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.production_vpc.id //where we want to create route table
  route {
    cidr_block = var.all_cidr //Handles outbound internet traffic for private subnets.
    nat_gateway_id = aws_nat_gateway.nat_gw.id 
  }
  tags = {
    Name="Private RT"
  }
}
#create the public subnet1
resource "aws_subnet" "public_subnet1" {
   vpc_id = aws_vpc.production_vpc.id
   cidr_block = var.public_subnet1_cidr
   availability_zone = "us-east-1b"
   map_public_ip_on_launch = true  //ensures EC2 instances get public IPs automatically.
   tags = {
    Name ="public subnet 1"
  }
}
#create the public subnet2
resource "aws_subnet" "public_subnet2" {
   vpc_id = aws_vpc.production_vpc.id
   cidr_block = var.public_subnet2_cidr
   availability_zone = "us-east-1b"
   map_public_ip_on_launch = true
   tags = {
    Name ="public subnet 2"
  }
}
#create the private subnet
resource "aws_subnet" "private_subnet" {
   vpc_id = aws_vpc.production_vpc.id
   cidr_block = var.private_subnet_cidr
   availability_zone = "us-east-1b"
   tags = {
    Name ="private subnet"
  }
}
#associate public route table with public subnet1
resource "aws_route_table_association" "public_association1" {
  subnet_id = aws_subnet.public_subnet1.id     //Links the public subnet to the public route table.
  route_table_id = aws_route_table.public_rt.id  
}

#creating jenkins security groups using tf
# If inbound is allowed, outbound responses are automatically allowed.
resource "aws_security_group" "jenkins_sg" {
 name="jenkins sg"
 description="allow ports 8080 and 22"
 vpc_id=aws_vpc.production_vpc.id
 ingress {
  description = "jenkins"
  from_port = var.jenkins_port   //Allows port 8080 (Jenkins UI) and port 22 (SSH) from anywhere (0.0.0.0/0).
  to_port = var.jenkins_port
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 } 
  ingress {
  description = "SSH"
  from_port = var.ssh_port
  to_port = var.ssh_port
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 } 
 egress {
  from_port=0 // allow outbound traffic on any port 
  to_port=0
  protocol= "-1"  //represent any protocol 
  cidr_blocks = ["0.0.0.0/0"]
 }
 tags ={ 
  name="Jenkins sg" 
  }

}

#creating sonarqube security groups using tf
# If inbound is allowed, outbound responses are automatically allowed.
resource "aws_security_group" "sonarqube_sg" {
 name="sonarqube sg"
 description="allow ports 9000 and 22"
 vpc_id=aws_vpc.production_vpc.id
 ingress {
  description = "jenkins"
  from_port = var.sonarqube_port   //Allows port 9000 (sonarqube UI) and port 22 (SSH) from anywhere (0.0.0.0/0).
  to_port = var.sonarqube_port
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 } 
  ingress {
  description = "SSH"
  from_port = var.ssh_port
  to_port = var.ssh_port
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 } 
 egress {
  from_port=0 // allow outbound traffic on any port 
  to_port=0
  protocol="-1"  //represent any protocol 
  cidr_blocks=["0.0.0.0/0"]
 }
 tags = {name="SONARQUBE SG"}
}
#creating grafana security groups using tf

resource "aws_security_group" "grafana_sg" {
 name="grafana sg"
 description="allow ports 3000 and 22"
 vpc_id=aws_vpc.production_vpc.id
 ingress {
  description = "grafana"
  from_port = var.grafana_port   //Allows port 3000 (GRAFANA UI) and port 22 (SSH) from anywhere (0.0.0.0/0).
  to_port = var.grafana_port
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 } 
  ingress {
  description = "SSH"
  from_port = var.ssh_port
  to_port = var.ssh_port
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 } 
 egress{
  from_port=0 // allow outbound traffic on any port 
  to_port=0
  protocol= "-1"  //represent any protocol 
  cidr_blocks=["0.0.0.0/0"]
 }
 tags = {name="GRAFANA SG"}
}

#creating ansible security groups using tf

resource "aws_security_group" "ansible_sg" {
 name="ansible sg"
 description="allow port 22" // ANSIBLE doest not have UI
 vpc_id=aws_vpc.production_vpc.id
 
  ingress {
  description = "SSH"
  from_port = var.ssh_port
  to_port = var.ssh_port
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 } 
 egress {
  from_port=0// allow outbound traffic on any port 
  to_port=0
  protocol= "-1 "//represent any protocol 
  cidr_blocks=["0.0.0.0/0"]
 }
 tags = {name="ANSIBLE SG"}
}

#creating application security groups using tf

resource "aws_security_group" "app_sg" {
 name="app sg"
 description="allow ports 80 and 22"
 vpc_id=aws_vpc.production_vpc.id
 ingress {
  description = "application"
  from_port = var.http_port   //Allows port 80 (APP UI) and port 22 (SSH) from anywhere (0.0.0.0/0).
  to_port = var.http_port
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 } 
  ingress {
  description = "SSH"
  from_port = var.ssh_port
  to_port = var.ssh_port
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 } 
 egress {
  from_port= 0 // allow outbound traffic on any port 
  to_port=0
  protocol= -1  //represent any protocol 
  cidr_blocks=["0.0.0.0/0"]
 }
 tags = {name="APPLICATION SG"}
}

#creating Load balancer security groups using tf

resource "aws_security_group" "lb_sg" {
 name="loadbalancer sg"
 description="allow port 22"
 vpc_id=aws_vpc.production_vpc.id
 ingress {
  description = "loadbalancer"
  from_port = var.http_port   //Allows port 80 (APP UI) and port 22 (SSH) from anywhere (0.0.0.0/0).
  to_port = var.http_port
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
 } 
 egress {
  from_port= 0 // allow outbound traffic on any port 
  to_port=0
  protocol= "-1 " //represent any protocol 
  cidr_blocks=["0.0.0.0/0"]
 }
 tags = {name="LOADBALANCER SG"}
}

# create ACL(access control list)
resource "aws_network_acl" "nacl" {
  vpc_id = aws_vpc.production_vpc.id
  subnet_ids = [ aws_subnet.public_subnet1.id,aws_subnet.public_subnet2.id,aws_subnet.private_subnet.id ]
  egress {
    protocol = "tcp"
    rule_no = "100"
    action = "allow"
    cidr_block = var.vpc_cidr
    from_port = 0
    to_port = 0
  }
  ingress {
     protocol = "tcp"
    rule_no = "100"
    action = "allow"
    cidr_block = var.all_cidr
    from_port = var.http_port
    to_port = var.http_port
  }
  ingress {
     protocol = "tcp"
    rule_no = "101"
    action = "allow"
    cidr_block = var.all_cidr
    from_port = var.ssh_port
    to_port = var.ssh_port
  }
  ingress {
     protocol = "tcp"
    rule_no = "102"
    action = "allow"
    cidr_block = var.all_cidr
    from_port = var.jenkins_port
    to_port = var.jenkins_port
  }
  ingress {
     protocol = "tcp"
    rule_no = "103"
    action = "allow"
    cidr_block = var.all_cidr
    from_port = var.sonarqube_port
    to_port = var.sonarqube_port
  }
  ingress {
     protocol = "tcp"
    rule_no = "104"
    action = "allow"
    cidr_block = var.all_cidr
    from_port = var.grafana_port
    to_port = var.grafana_port
  }
  tags = {
    name="Main ACL"
  }
}