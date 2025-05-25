# Key pair needed for login
resource "aws_key_pair" "my_key" {
  key_name   = "terra-key-ansible"
  public_key = file("terra-key-ansible.pub")
}

# Default VPC
resource "aws_default_vpc" "default" {}

# Security Group
resource "aws_security_group" "my_sec_group" {
  name        = "ansible-sg"
  description = "This is a ansible generated sec-group"
  vpc_id      = aws_default_vpc.default.id

  # Inbound Rules
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH open"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP open"
  }

  # Outbound Rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All access to ports"
  }

  tags = {
    Name = "ansible-sg"
  }
}
   #ec2 instance
   resource "aws_instance" "my_instance" {
     for_each = tomap({
        ansible_master = "ami-0df368112825f8d8f" #ubuntu 22.04
        ansible_slave1 = "ami-01abff0fb51badaf8" #Red Hat
        ansible_slave2 = "ami-03d8b47244d950bbb" #Amazon Linux 2
     })
     key_name          = aws_key_pair.my_key.key_name
     security_groups   = [aws_security_group.my_sec_group.name]
     instance_type     = "t2.micro"
     ami               = each.value
     root_block_device {
       volume_size = 10
       volume_type = "gp3"
     }
     tags = {
       Name        = each.key
     }
   }