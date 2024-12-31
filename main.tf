# Configure the AWS provider
provider "aws" {
  region = "ap-south-1" # Replace with the desired AWS region NV
}

# Create a security group
resource "aws_security_group" "allow_all" {
  name        = "allow_all_sg1"
  description = "Security group with all inbound and outbound traffic allowed"

  # Allow all inbound traffic
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an EC2 instance
resource "aws_instance" "my_instance" {
  ami           = "ami-0fd05997b4dff7aac" # DEBIAN 12 AMI
  instance_type = "t2.micro" # You can adjust the instance size


 # EC2 Tags
  tags = {
    Name = "AnsibleManagedInstance"
  }
# Output the private IP address for use later
  provisioner "local-exec" {
    command = <<-EOT
      echo "[webservers]" > inventory.ini
      echo "${self.private_ip}" >> inventory.ini
    EOT
  }

 # Optionally, you can also output the IP for later use
  output "private_ip" {
    value = aws_instance.example.private_ip
  }
}

# You can also output the private IP address from Terraform
output "instance_private_ip" {
  value = aws_instance.example.private_ip
}


  # Associate the instance with the security group
  security_groups = [aws_security_group.allow_all.name]

  key_name = aws_key_pair.my_key.key_name # Key pair for SSH access

  # To make the instance accessible via SSH (PuTTY requires .ppk format)
  tags = {
    Name = "MyTerraformEC2Instance1"
  }

  # Set the instance to be accessible via SSH
}

# Create an SSH key pair
resource "aws_key_pair" "my_key" {
  key_name   = "my-ssh-key1"
  public_key = file("~/.ssh/id_rsa.pub")  # Ensure you have the key already generated
}
