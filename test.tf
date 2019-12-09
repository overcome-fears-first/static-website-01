resource "aws_key_pair" "deployer_1" {
  key_name   = "deployer_key_name_1"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLnYL0XELYn9p1XkpypagdsLwRo3fuDU24KuMOMsX2nLDyzmQtyyOz1bY+Y7tXV9Ny6Z9uTadSx3ckbLy43BgKqjY7OOuxLFGsAgqXaZeFXMqPesDrH96+MXX6CcfuktfGlYfUz2NPgyfml34568Lho6oGiGZw8eYISUl5vociWxSkl8q5ymWFEUpYWenL/D8Nt+szQ2XK6AxpUx/rsfvrXFRtGj1eMhCQXfeMZPZpd39v3qWEzd4zVBio+D7Yo7I2jx+1HeTtXtfSsPiZxvMzotEGqJhWyOf/3imE/wEov6+vQehPWEtd/GS1m9ZGtd1P2RCLh86ku8MitVzvRGS/"
}

variable "server_prefix" {
  default = "default"
}

variable "instance_count" {
  default = "2"
}

# Configure the AWS Provider
provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}



# Create a new instance of the latest Ubuntu 14.04 on an
# t2.micro node with an AWS Tag naming it "HelloWorld"
#provider "aws" {
#  region = "us-west-2"
#}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.example.id
  cidr_block = "10.0.0.0/24"
  #availability_zone = "us-east-1"

  tags = {
    Name = "search-subnet-1"
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  count         = var.instance_count
  key_name      = aws_key_pair.deployer_1.key_name
  #subnet_id     = aws_subnet.my_subnet.id

  tags = {
    Name = "${var.server_prefix}-${count.index + 1}"
  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip} >> public_ips.txt"

    connection {
          host     = self.public_ip
          type     = "ssh"
          user     = "ubuntu"
          private_key = file("~/.ssh/key/key.pem.insecure")
    }
  }

  provisioner "file" {
    source      = "testfile.txt"
    destination = "testfile.txt"

    connection {
          host     = self.public_ip
          type     = "ssh"
          user     = "ubuntu"
          private_key = file("~/.ssh/key/key.pem.insecure")
    }
  }
}

