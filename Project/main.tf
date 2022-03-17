# 1) create a vpc
provider "vpc" {
    region = "us-east-1"  
    access_key = "key"
    secret_key = "key"
}
resource "aws_vpc" "production_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
      name = "Production"
    }  
}


# 2) create internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.production_vpc.id

  tags = {
    Name = "main_gateway"
  }
}

# 3) create custom route table
resource "aws_route_table" "main-route-table" {
    vpc_id = aws_vpc.production_vpc.id
    
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "prod"
  }
}

# 4) create subnet
resource "aws_subnet" "subnet_1" {
  vpc_id     = aws_vpc.production_vpc.id 
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Production_Subnet"
  }
}

# 5) associate subnet with route tabel
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.main-route-table.id
}
# 6) create a security group to allow port 22.00.443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web traffic"
  vpc_id      = aws_vpc.production_vpc.id

  ingress {
    description      = "HTTPS"
    from_port        = 443 #this is just the range of port
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] #anyone ip address can access it 
  }
# if u need it on http and ssh 
  ingress {
    description      = "HTTP"
    from_port        = 80 #this is just the range of port
    to_port          = 80
    protocol         = "-1" #-1 means any protocol
    cidr_blocks      = ["0.0.0.0/0"] #anyone ip address can access it 
  }
  ingress {
    description      = "ssh"
    from_port        = 2 #this is just the range of port
    to_port          = 2
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] #anyone ip address can access it 
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

# 7) create an network interface with an ip in the subnet that was crated in step 4
resource "aws_network_interface" "my_network_interface" {
  subnet_id       = aws_subnet.subnet_1.id #4) id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]
}

# 8) assign an elastic ip to the network interface created in step 7
resource "aws_eip" "one" {
  vpc                       = true #Boolean if the EIP is in a VPC or not
  network_interface         = aws_network_interface.my_network_interface.id
  associate_with_private_ip = "10.0.1.10"
  #here lets create a depend on 
  depends_on = [aws_internet_gateway.gw]
}
# 9) create an ubuntu server and install/enable apache2
resource "aws_instance" "My_First_Server" {
    ami = "ami-0e472ba40eb589f49" # this part will be in aws amazon 
    instance_type = "t2.micro" # what ever u want 
    availability_zone = "us-east-1a"
    key_name = "main_key" # this is the key pair file that we have created in aws

    network_interface {
        device_index = 0  # everything realted to network interface in the terraform doc
        network_interface_id = aws_network_interface.my_network_interface.id # 7) id 
    }

# user_data : what ever u want to run , install in server that we have created 
    user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c 'echo hello world > /var/www/html/index.html'
                EOF 
                #the start and the end must be with EOF
    tags = {
      name = "S1" # tag : it will just describe what name we need for the server
    }
}



