terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-1"
  access_key = "AKIAQJ7L5QKNWSYZHSQI"
  secret_key = "**********************"
}


locals {
  vpc_id= "vpc-01ef6b5f02c2c0d6e"
  subnet_id= "subnet-08620699f1f4ff36e"
  ssh_user= "ubuntu"
  key_name= "terraformkey"
  private_key_path= "~/Downloads/terra/terraformkey.pem"
}

/*
//security.tf
resource "aws_security_group" "ngin" {
name = "ngin_access"
vpc_id = local.vpc_id
ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
from_port = 22
    to_port = 22
    protocol = "tcp"
  }
ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
from_port = 80
    to_port = 80
    protocol = "tcp"
  }

// Terraform removes the default rule
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}
*/

//servers.tf
resource "aws_instance" "nginx" {
  ami = "ami-01154c8b2e9a14885"
  instance_type = "t2.micro"
  key_name = "terraformkey"
  security_groups = ["launch-wizard-1"]

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'",
              "sudo apt update",
              "sudo apt install software-properties-common -y",
              "sudo add-apt-repository --yes --update ppa:ansible/ansible",
              "sudo apt install ansible -y",
              "ansible --version"]
    connection {
        type = "ssh"
        user = local.ssh_user
        private_key = file(local.private_key_path)
        host = aws_instance.nginx.public_ip
    } 
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i ${aws_instance.nginx.public_ip}, --private_Key ${local.private_key_path} nginx.yml" 
  }
}

output "nginx_ip" {
    value = aws_instance.nginx.public_ip
  
}