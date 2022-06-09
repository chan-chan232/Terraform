provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "myfirstvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "myfirstvpc"
  }
}

resource "aws_internet_gateway" "Igw" {
  vpc_id = aws_vpc.myfirstvpc.id

  tags = {
    Name = "Igw"
  }
}

resource "aws_subnet" "publicsubnet" {
  vpc_id                  = aws_vpc.myfirstvpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "publicsubnet"
  }
}


resource "aws_subnet" "privatesubnet" {
  vpc_id     = aws_vpc.myfirstvpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "privatesubnet"
  }
}

resource "aws_route_table" "routetable" {
  vpc_id    = aws_vpc.myfirstvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Igw.id

  }

  tags = {
    Name = "routetable"
  }
}
/*
resource "aws_instance" "myfirstec2" {
  ami           = "ami-0022f774911c1d690" 
  instance_type = "t2.micro"

  } */
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.myfirstvpc.id

  ingress {
    description = "SSH from VPC"
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

  tags = {
    Name = "allow_ssh"
  }

}

resource "aws_instance" "myfirstinstance" {
  instance_type = "t2.micro"
  ami           = "ami-0022f774911c1d690"
  subnet_id     = aws_subnet.publicsubnet.id
  associate_public_ip_address = true
  key_name      = "Terraform"

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  tags = {
    type = "myfirstinstance"
  }
}
/*
resource "aws_network_interface" "nft_pub" {
  subnet_id       = aws_subnet.publicsubnet.id
  private_ips     = ["10.0.2.0"]
  security_groups = [aws_security_group.main-sg.id]

  attachment {
    instance     = aws_instance.myfirstinstance.id
    device_index = 1
  }
}
*/

/* resource "aws_security_group" "main-sg" {
  tags = {
    type = "main-sg"
  }
} */
/*
resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = aws_security_group.main-sg.id
  network_interface_id = aws_network_interface.nft_pub.id
} */

