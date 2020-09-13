#Initialize the KeyPair
resource "aws_key_pair" "default" {
  key_name = "ssh_jenkins"
  public_key = file("ssh_jenkins.pem")
}

resource "aws_vpc" "CICDvpc" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    tags = {
        Name = "Jenkins_Build_Server"
    }
}

resource "aws_subnet" "public-subnet-1" { 
    vpc_id  = aws_vpc.CICDvpc.id
    cidr_block  = var.public_subnet_1_cidr  
    availability_zone = "${var.regionlocal}a"
    tags = {
        Name = "DevSecOps-Public-Subnet-1"
    }
}

resource "aws_subnet" "private-subnet-1" { 
    vpc_id  = aws_vpc.CICDvpc.id
    cidr_block  = var.private_subnet_1_cidr  
    availability_zone = "${var.regionlocal}a"
    tags = {
        Name = "DevSecOps-Private-Subnet-1"
  }
}

resource "aws_route_table" "public-route-table" {
    vpc_id = aws_vpc.CICDvpc.id
    tags = {
        Name = "Public-RouteTable"
    }
  }
  
resource "aws_route_table" "private-route-table" {
    vpc_id = aws_vpc.CICDvpc.id
    tags = {
        Name = "Private-RouteTable"
    }
  }
 
resource "aws_route_table_association" "public-route-1-association" {
  route_table_id = aws_route_table.public-route-table.id
  subnet_id      = aws_subnet.public-subnet-1.id
}

resource "aws_route_table_association" "private-route-1-association" {
  route_table_id = aws_route_table.private-route-table.id
  subnet_id      = aws_subnet.private-subnet-1.id
}

resource "aws_eip" "elastic-ip-for-nat-gw" {
  vpc  = true
  associate_with_private_ip = "10.0.0.5"
  tags = {
    Name = "EIP"
  }
}

resource "aws_nat_gateway" "nat-gw" {
    allocation_id = aws_eip.elastic-ip-for-nat-gw.id
  subnet_id     = aws_subnet.public-subnet-1.id
  tags = {
    Name = "NATGW"
  }
  depends_on = [aws_eip.elastic-ip-for-nat-gw]

}
    
resource "aws_route" "nat-gw-route" {
  route_table_id         = aws_route_table.private-route-table.id 
  nat_gateway_id         = aws_nat_gateway.nat-gw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_internet_gateway" "DevSecOps-igw" {
  vpc_id = aws_vpc.CICDvpc.id
  tags = {
    Name = "IGW"
  }
}

resource "aws_route" "public-internet-igw-route" {
  route_table_id         = aws_route_table.public-route-table.id
  gateway_id             = aws_internet_gateway.DevSecOps-igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_security_group" "jenkins_sg" {
    name = "securitygroup"
    vpc_id = aws_vpc.CICDvpc.id
    
    dynamic "ingress" {
        iterator = port
        for_each = var.ingressrules
        content {
            from_port = port.value
            to_port = port.value
            protocol = "TCP"
            cidr_blocks = ["0.0.0.0/0"]
           }
           }
            
            
            egress {
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
            
        }
        
    }
