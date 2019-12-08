resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDLd0OZUBYHTxZQlHyU7gQiq2cgvi5s9Z6Joi0mPSAJ4/Csr3wcod50VTbNmWqCdcDzwRAeOdL2eNoyz6IqTWeJFBTqb6kHE6KLADvaQy9YjrkutXhRYQJXnF4e22NDrYNhNR4SnFACYpNb+ZTmlcOC6B+8Iw8LXhSbEzC2XHBs2MrSfZsEONQ3Sg9boGiEjI1pCrrgODypUob7B4gkjntv+b74ENgBqZr/UYNwM1pHGBmYvbYz48odfZDu72igjzJ/Wmt6KfwpDAchWxekHkMfDhCedY4YHJsoVw5QI07DpUTJM49gGVQGlZ8CdPogqbQ2EtIK5ytMcDFZJY6lZ8sfmlocPTON0sPlhPevdSaTOqmjEnDxznGnyIOrDMDNVMFsc+Zw2B4k/e7lUOFeEWD7mh8KQQCheb6olHuGy4vWyjg9uBpot0TJUZvs9luSYYf9No2BWHzaEf9FXWjW4x8BMPmCLxRo5JEVbhfGO3twLZ1z2IU4+uGkiNJht8PGADc= overcome.fears.first@gmail.com"
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
  key_name      = aws_key_pair.deployer.key_name
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
          private_key = file("~/.ssh/yourname.pem.insecure")
    }
  }

  provisioner "file" {
    source      = "testfile.txt"
    destination = "testfile.txt"

    connection {
          host     = self.public_ip
          type     = "ssh"
          user     = "ubuntu"
          private_key = file("~/.ssh/yourname.pem.insecure")
    }
  }
}

