terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "lab-my-tf-state1"          
    key            = "terraform.tfstate"        
    region         = "eu-north-1"               
    dynamodb_table = "lab-my-tf-lockid"         
    encrypt        = true                       
  }
}

provider "aws" {
  region = "eu-north-1"  
}

resource "aws_security_group" "lab_sg" {
  name        = "lab-security-group2"
  description = "Security group for lab application"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8086
    to_port     = 8086
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Lab_security"
    Project = "MIT31-lab6"
  }
}


resource "aws_instance" "lab_server" {
  ami                    = "ami-0f50f13aefb6c0a5d"  
  instance_type          = "t3.micro"              
  vpc_security_group_ids = [aws_security_group.lab_sg.id]


  key_name = "ec2-key-pair"  

  tags = {
    Name    = "Lab-MIT31"
    Project = "Technology-MIT31"
    Student = "Йовхимищ Діана"
  }


  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -a -G docker ec2-user
              EOF
}


output "server_ip" {
  value = aws_instance.lab_server.public_ip
  description = "Public IP address of the lab server"
}

output "server_url" {
  value = "http://${aws_instance.lab_server.public_ip}"
  description = "URL to access the application"
}
