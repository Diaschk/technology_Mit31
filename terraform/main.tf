

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"  # Можете змінити на свій регіон
}

# 1. Security Group (група безпеки)
resource "aws_security_group" "lab_sg" {
  name        = "lab-security-group"
  description = "Security group for lab application"

  # Дозволяємо вхідний трафік HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Дозволяємо вхідний трафік HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Дозволяємо вхідний трафік SSH (для підключення)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Дозволяємо вихідний трафік на всі порти
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "LabSecurityGroup"
    Project = "MIT31-Lab6"
  }
}

# 2. EC2 Instance (віртуальна машина)
resource "aws_instance" "lab_server" {
  ami                    = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI
  instance_type          = "t2.micro"               # Безкоштовний рівень
  vpc_security_group_ids = [aws_security_group.lab_sg.id]

  # Ключ для SSH (потрібно створити в AWS Console)
  key_name = "lab-key"  # Змініть на назву вашого ключа

  tags = {
    Name    = "LabServer-MIT31"
    Project = "Technology-MIT31"
    Student = "Йовхимищ Діана"
  }

  # Користувацькі дані для налаштування при запуску
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -a -G docker ec2-user
              EOF
}

# Вивід IP адреси сервера
output "server_ip" {
  value = aws_instance.lab_server.public_ip
  description = "Public IP address of the lab server"
}

output "server_url" {
  value = "http://${aws_instance.lab_server.public_ip}"
  description = "URL to access the application"
}
