provider "aws" {
  access_key = ""
  secret_key = ""
  region     = "ap-south-1"
}

# Security Group
resource "aws_security_group" "allow-ssh-and-http" {
vpc_id = "${aws_vpc.main.id}"
name = "allow-ssh"
description = "security group that allows ssh and all egress traffic"
egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
}
ingress {
from_port = 22
to_port = 22
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
ingress {
from_port = 80
to_port = 80
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
ingress {
from_port = 8080
to_port = 8080
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
tags {
Name = "allow-ssh-and-http"
}
}

# Internet VPC
resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    tags {
        Name = "main"
    }
}


# Subnets
resource "aws_subnet" "main-public-1" {
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "ap-south-1a"

    tags {
        Name = "main-public-1"
    }
}


# Internet GW
resource "aws_internet_gateway" "main-gw" {
    vpc_id = "${aws_vpc.main.id}"

    tags {
        Name = "main"
    }
}

# route tables
resource "aws_route_table" "main-public" {
    vpc_id = "${aws_vpc.main.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.main-gw.id}"
    }

    tags {
        Name = "main-public-1"
    }
}

# route associations public
resource "aws_route_table_association" "main-public-1-a" {
    subnet_id = "${aws_subnet.main-public-1.id}"
    route_table_id = "${aws_route_table.main-public.id}"
}


# Autoscaling
resource "aws_launch_configuration" "pradipta-launchconfig" {
name_prefix = "pradipta-launchconfig"
image_id = "ami-0d773a3b7bb2bb1c1"
instance_type = "t2.micro"
key_name = "pg"
security_groups = ["${aws_security_group.allow-ssh-and-http.id}"]
}
resource "aws_autoscaling_group" "pradipta-autoscaling" {
name = "pradipta-autoscaling"
vpc_zone_identifier = ["${aws_subnet.main-public-1.id}"]
launch_configuration = "${aws_launch_configuration.pradipta-launchconfig.name}"
min_size = 1
max_size = 5
force_delete = true
tag {
key = "Name"
value = "webserver8080"
propagate_at_launch = true
}
}
