provider "aws" {
  region = "eu-north-1"
}

# Fetching the VPC named Application-Vpc
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["my-vpc-001"]
  }
}

data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"] # Amazon's owner ID
}

# Create EC2 instance
resource "aws_instance" "example" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"

  # Using the first subnet from the fetched list
  subnet_id = tolist(data.aws_subnets.selected.ids)[0]

  tags = {
    Name = "MyInstance"
  }
}
