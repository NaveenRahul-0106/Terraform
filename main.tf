terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = "true"
  

  tags = {
    Name = "my-vpc"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_igw"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "public-subnet"
  }
}

# resource "aws_subnet" "private_subnet" {
#   vpc_id     = aws_vpc.my_vpc.id
#   cidr_block = "10.0.1.0/24"

#   tags = {
#     Name = "private-subnet"
#   }
# }

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "pb_rt_asc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# resource "aws_route_table" "private_rt" {
#   vpc_id = aws_vpc.my_vpc.id

#   tags = {
#     Name = "private-rt"
#   }
# }

# resource "aws_route_table_association" "pr_rt_asc" {
#   subnet_id      = aws_subnet.private_subnet.id
#   route_table_id = aws_route_table.private_rt.id
# }

resource "aws_route" "r" {
  route_table_id            = aws_route_table.public_rt.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.my_igw.id
}

# data "aws_ami" "amazon_linux" {
#   most_recent = true
# }

# output "ami_id" {
#   description = "ID of the ami"
#   value       = data.aws_ami.amazon_linux.id
# }

resource "aws_instance" "my_EC2_public" {
  ami           = "ami-0574da719dca65348"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.my_public_ec2.id]
  key_name = "office"
  associate_public_ip_address = "true"
  user_data = "${file("docker-install.sh")}"
  tags = {
    Name = "docker_demo"
  }
}

resource "aws_security_group" "my_public_ec2" {
  name        = "allow ssh"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description      = "SSH VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["115.246.252.237/32"]
  }

   ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

# resource "aws_instance" "my_EC2_private" {
#   ami           = "ami-0b0dcb5067f052a63"
#   instance_type = "t2.micro"
#   subnet_id = aws_subnet.private_subnet.id
#   security_groups = [aws_security_group.my_private_ec2_sg.id]
#   key_name = "office"

#   tags = {
#     Name = "my_EC2_private"
#   }
# }

# resource "aws_security_group" "my_private_ec2_sg" {
#   name        = "allow ssh_pvt"
#   vpc_id      = aws_vpc.my_vpc.id

#   ingress {
#     description      = "SSH VPC"
#     from_port        = 22
#     to_port          = 22
#     protocol         = "tcp"
#     cidr_blocks      = ["${aws_instance.my_EC2_public.private_ip}/32"]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   tags = {
#     Name = "allow_ssh_pvt"
#   }
# }

# resource "aws_eip" "eip" {
#   vpc      = true
# }

# resource "aws_nat_gateway" "gw_NAT" {
#   allocation_id = aws_eip.eip.id
#   subnet_id     = aws_subnet.public_subnet.id

#   tags = {
#     Name = "gw_NAT"
#   }

#   # To ensure proper ordering, it is recommended to add an explicit dependency
#   # on the Internet Gateway for the VPC.
#   depends_on = [aws_internet_gateway.my_igw]
# }


# resource "aws_route" "route-nat" {
#   route_table_id            = aws_route_table.private_rt.id
#   destination_cidr_block    = "0.0.0.0/0"
#   nat_gateway_id  = aws_nat_gateway.gw_NAT.id
# }




### load balancer ####

# resource "aws_security_group" "my_alb_sg" {
#   name        = "my_alb_sg"
#   vpc_id      = aws_vpc.my_vpc.id

#   ingress {
#     description      = "http"
#     from_port        = 80
#     to_port          = 80
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   tags = {
#     Name = "my_alb_sg"
#   }
# }


# resource "aws_lb" "my_alb" {
#   name               = "myalb"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.my_alb_sg.id]
#   subnets = [aws_subnet.public_subnet.id,aws_subnet.private_subnet.id]
#   ip_address_type = "ipv4"
#   enable_deletion_protection = true

# }

# resource "aws_lb_target_group" "my_tg_group" {
#   name     = "mytggroup"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.my_vpc.id
#     tags = {
#     Name = "my_tg_group"
#   }
# }

# resource "aws_lb_listener" "alb-listener" {
#   load_balancer_arn = aws_lb.my_alb.id
#   port              = "80"
#   protocol          = "HTTP"
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.my_tg_group.arn
#   }

# }

# resource "aws_lb_target_group_attachment" "test" {
#   target_group_arn = aws_lb_target_group.my_tg_group.arn
#   target_id        = aws_instance.my_EC2_public.id
#   port             = 80
# }
