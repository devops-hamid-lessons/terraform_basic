provider "aws" {
  //  access_key = ""
  //  secret_key = ""
    region = var.region
}

// variables ************************************
variable "region" {}
variable "vpc_cidr_block" {}
variable "subnet_cidr_blocks" {
  type = list(string)
}
variable "availability_zone" {}
variable "env_prefix" {}
variable "instance_type" {}
variable "public_key_location" {}
variable "initial_script_location" {}

// vpc ************************************
resource "aws_vpc" "myapp_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name: "${var.env_prefix}-vpc"
  }
}

// subnets ************************************
resource "aws_subnet" "myapp_subnet_1" {
  cidr_block = var.subnet_cidr_blocks[0]
  vpc_id = aws_vpc.myapp_vpc.id
  availability_zone = var.availability_zone
  tags = {
    Name: "${var.env_prefix}-subnet-1"
  }
}

// routing table ************************************

// to create a new route table
/*
resource "aws_route_table" "myapp_rtb" {
  vpc_id = aws_vpc.myapp_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp_igw.id
  }
  tags = {
    Name: "${var.env_prefix}-rtb"
  }
}
resource "aws_route_table_association" "myapp_associate_rtb_to_subnet" {
  route_table_id = aws_route_table.myapp_rtb.id
  subnet_id = aws_subnet.myapp_subnet_1.id
}
*/

// to use the default route table
resource "aws_default_route_table" "myapp_default_rtb" {
  default_route_table_id = aws_vpc.myapp_vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp_igw.id
  }
  tags = {
    Name: "${var.env_prefix}-main-rtb"
  }
}

resource "aws_internet_gateway" "myapp_igw" {
  vpc_id = aws_vpc.myapp_vpc.id
  tags = {
    Name: "${var.env_prefix}-igw"
  }
}

// security group ************************************

//to create and configure a new sg
/*
resource "aws_security_group" "myapp_sg" {
  vpc_id = aws_vpc.myapp_vpc.id
  name = "myapp_sg"
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 8080
    protocol = "tcp"
    to_port = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
    Name: "${var.env_prefix}-sg"
  }
}
*/

//to use and configure the default sg
resource "aws_default_security_group" "myapp_default_sg" {
  vpc_id = aws_vpc.myapp_vpc.id
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 8080
    protocol = "tcp"
    to_port = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
    Name: "${var.env_prefix}-default-sg"
  }
}

// create an instance ************************************
// go to "ec2->Images(ami catalog) -> Community AMIs" to see fields and perform filter
data "aws_ami" "latest_ubuntu_linux_image"{
  most_recent = true
  owners = ["amazon"]
  filter{
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

//resource "aws_key_pair" "my_keypair" {
//  key_name = "server_key"
//  public_key = file(var.public_key_location)
//}
resource "aws_instance" "myapp_server" {
  ami = data.aws_ami.latest_ubuntu_linux_image.id  //you can also define AMI Id
  instance_type = var.instance_type
  subnet_id = aws_subnet.myapp_subnet_1.id
  vpc_security_group_ids = [aws_default_security_group.myapp_default_sg.id]
  availability_zone = var.availability_zone
  associate_public_ip_address = true
//  key_name = aws_key_pair.my_keypair.key_name //this is for the time when you want to use your own created key-pair.
  key_name = "server-key" //server-key is the name of the key created inside aws.
  user_data = file(var.initial_script_location)
  tags = {
    Name: "${var.env_prefix}-server"
  }
}

output "myapp_server_ip" {
  value = aws_instance.myapp_server.public_ip
}