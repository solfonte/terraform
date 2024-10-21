# terraform block
terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.0"
        }
    }
}

# define aws access key variables
variable "access_key" { type = string } 
variable "secret_key" { type = string } 

# set up cloud provider
provider "aws" {
  region = "us-east-1"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

# set up EC2 virtual machine
resource "aws_instance" "example" {
    ami = "ami-0c55b159cbfafe1f0"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.instance.id]
    
    user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World" > index.html
    nohup busybox httpd -f -p 8080 &
    EOF

    tags = {
        Name = "terraform-example"
    }
}

# To allow the EC2 Instance to receive traffic on port 8080, you need to create a security group
resource "aws_security_group" "instance" {
    name = "terraform-example-instance"
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# instead of having to manually poke around the EC2 console to
# find the IP address of your server, you can provide the IP address as an
# output variable
output "public_ip" {
    value = aws_instance.example.public_ip
    description = "The public IP address of the web server"
}


#"LKIAQAAAAAAAFXMTDSWU"
#"DlMa2CAr/8HPWWuD7JCy/8H9MyedBQsL7Rv/fIfD"