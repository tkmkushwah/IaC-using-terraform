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

# resource "aws_nat_gateway" "nat_gw" {
#   allocation_id = aws_eip.nat_eip.id
#   subnet_id = aws_subnet.public_subnet1.id
#   tags = {
#     Name ="NAT Gateway" 
#   }

# }