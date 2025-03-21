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
resource "aws_eip" "nat_eip" {
  depends_on = [ aws_internet_gateway.igw ]
}

# create the nat gateway

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
    cidr_block = var.all_cidr
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
    cidr_block = var.all_cidr
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
   map_public_ip_on_launch = true
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
  subnet_id = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_rt.id  
}

#creating jenkins security groups using tf

resource "aws_security_group" "jenkins_sg" {
 name="jenkins sg"
 description="allow ports 8080 and 22"
 vpc_id=aws_vpc.production_vpc.id
 ingress {
  description = "jenkins"
  from_port = var.jenkins_port
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
 egress = {
  from_port= "0" // allow outbound traffic on any port 
  to_port="0"
  protocol= "-1"  //represent any protocol 
  cidr_block=["0.0.0.0/0"]
 }
 tags = "JENKINS SG"
}