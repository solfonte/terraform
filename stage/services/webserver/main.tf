# terraform block
terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.0"
        }
    }

   /*  backend "s3" {
        bucket = "state-file-storage"
        key = "global/s3/terraform.tfstate"
        region = "us-east-1"

        dynamodb_table = "state-file-lock"
        encrypt = true
    } */
}

# set up cloud provider
provider "aws" {
  region = "us-east-1"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"

    s3_use_path_style = true

  endpoints {
    apigateway     = "http://localhost:4566"
    cloudformation = "http://localhost:4566"
    cloudwatch     = "http://localhost:4566"
    dynamodb       = "http://localhost:4566"
    es             = "http://localhost:4566"
    firehose       = "http://localhost:4566"
    iam            = "http://localhost:4566"
    kinesis        = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    route53        = "http://localhost:4566"
    redshift       = "http://localhost:4566"
    s3             = "http://s3.localhost.localstack.cloud:4566"
    secretsmanager = "http://localhost:4566"
    ses            = "http://localhost:4566"
    sns            = "http://localhost:4566"
    sqs            = "http://localhost:4566"
    ssm            = "http://localhost:4566"
    stepfunctions  = "http://localhost:4566"
    sts            = "http://localhost:4566"
    ec2            = "http://localhost:4566"
  }
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

#"LKIAQAAAAAAADYXTP5UN"
#"k/33LfT6vQ9MBYGOK98UPmaHOtPz6vdXZRWuZQyk"