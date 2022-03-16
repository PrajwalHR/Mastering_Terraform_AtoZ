provider "vpc" {
    region = "us-east-1"  
    access_key = "key"
    secret_key = "key"
}

resource "aws_vpc" "first_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
      name = "Production"
    }
  
}

resource "aws_subnet" "subnet_1" {
  vpc_id     = aws_vpc.first_vpc.id #here i am calling out the line 7 to 13 code
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Production_Subnet"
  }
}
