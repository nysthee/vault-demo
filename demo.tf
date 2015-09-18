variable "aws_region" {
  default = "us-east-1"
}

provider "aws" {
  region = "${var.aws_region}"
}

variable "aws_amis" {
  default = {
    ap-northeast-1  = "ami-48c27448"
    ap-southeast-1  = "ami-86e3e1d4"
    ap-southeast-2  = "ami-21eea81b"
    cn-north-1      = "ami-9871eca1"
    eu-central-1    = "ami-88333695"
    eu-west-1       = "ami-c8a5eebf"
    sa-east-1       = "ami-1319960e"
    us-east-1       = "ami-d96cb0b2"
    us-gov-west-1   = "ami-25fc9c06"
    us-west-1       = "ami-6988752d"
    us-west-2       = "ami-d9353ae9"
  }
}

resource "aws_key_pair" "demo" {
  key_name   = "demo"
  public_key = "${file("${path.module}/keys/id_rsa.pub")}"
}

resource "aws_vpc" "demo" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags { Name = "demo" }
}

resource "aws_internet_gateway" "demo" {
  vpc_id = "${aws_vpc.demo.id}"
  tags { Name = "demo" }
}

resource "aws_subnet" "demo" {
  vpc_id = "${aws_vpc.demo.id}"
  cidr_block = "10.0.0.0/24"
  tags { Name = "demo" }

  map_public_ip_on_launch = true
}

resource "aws_route_table" "demo" {
  vpc_id = "${aws_vpc.demo.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.demo.id}"
  }

  tags { Name = "demo" }
}

resource "aws_route_table_association" "demo" {
  subnet_id = "${aws_subnet.demo.id}"
  route_table_id = "${aws_route_table.demo.id}"
}

resource "aws_security_group" "demo" {
  name   = "demo-web"
  vpc_id = "${aws_vpc.demo.id}"

  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "postgresql" {
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.demo.key_name}"
  subnet_id     = "${aws_subnet.demo.id}"

  vpc_security_group_ids = ["${aws_security_group.demo.id}"]

  connection {
    user     = "ubuntu"
    key_file = "${path.module}/keys/id_rsa"
  }

  tags { Name = "postgresql" }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/scripts/postgresql.sh",
    ]
  }
}

output "postgresql" { value = "${aws_instance.postgresql.public_ip}" }
