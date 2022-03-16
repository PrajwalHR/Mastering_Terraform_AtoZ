provider "aws" {
    region = "us-east-1"  
    access_key = "key"
    secret_key = "key"
}

# we can change the provider like azure , google cloud
# If we run it twice it will not create a new or same aws server 

resource "aws_instance" "My_First_Server" {
    ami = "ami-0e472ba40eb589f49"
    instance_type = "t2.micro"
    tags = {
      name = "S1"
    }
}
# github
# terraform init
# for dry run : terraform plan [ just like what if? in ansible ]
# terraform apply [ another what_IF? + it asky permission for each stage]
# done


