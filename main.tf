# terraform block
terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.0"
        }
    }

    backend "s3" {
        bucket = "state-file-storage"
        key = "global/s3/terraform.tfstate"
        region = "us-east-1"

        dynamodb_table = "state-file-lock"
        encrypt = true
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

resource "aws_security_group" "instance" {
    name = "terraform-example-instance"
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

output "public_ip" {
    value = aws_instance.example.public_ip
    description = "The public IP address of the web server"
}

# Bucket to store the terraform state file
resource "aws_s3_bucket" "terraform_state_storage" {
    bucket = "backend"

    # Prevent accidental deletion for this S3 bucket
    lifecycle {
        prevent_destroy = true
    }

    #versioning is deprecated
   #server_side_encryption_configuration is deprecated
}

# DynamoDB table to lock the state file with the primary key LockID
resource "aws_dynamodb_table" "terraform_locks" {
    name = "state-file-lock"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
      name = "LockID"
      type = "S"
    }
}



# "LKIAQAAAAAAABIMFELDE"
# "ikL3ryH7CwyK999rJVV/YfGoh0tP3AjJMW1oqTf3"