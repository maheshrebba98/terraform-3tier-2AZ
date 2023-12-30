provider "aws" {
region = "us-east-1"
access_key = "AKIAW4VCXAGH4RGJW75N"
secret_key = "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"
}
##########################
######   VPC    ##########
##########################
resource "aws_vpc" "vpc_01" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "central-network"
   }
}
##########################
######   IGW    ##########
##########################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_01.id
  tags = {
    Name = "Test-IGW"
  }
}
##########################
##  Public web Subnet -1 ##
##########################
resource "aws_subnet" "public-web-subnet-1" {
  vpc_id                  = aws_vpc.vpc_01.id
  cidr_block              = var.public-web-subnet-1-cidr
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public subnet -1"
  }
}
##########################
## Public web Subnet - 2 ##
##########################
resource "aws_subnet" "public-web-subnet-2" {
  vpc_id                  = aws_vpc.vpc_01.id
  cidr_block              = var.public-web-subnet-2-cidr
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public subnet -2"
  }
}
##########################
######  Public Route table  #####
##########################
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc_01.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "Public Route table"
  }
}
##########################
## Route table Assoc for Web tier ##
##########################
resource "aws_route_table_association" "public-subnet-1-route-table-association" {
  subnet_id      = aws_subnet.public-web-subnet-1.id
  route_table_id = aws_route_table.public-route-table.id
}
##########################
## Private App Subnet -1 ##
##########################
resource "aws_subnet" "private-app-subnet-1" {
  vpc_id                  = aws_vpc.vpc_01.id
  cidr_block              = var.private-app-subnet-1-cidr
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private APP subnet -1"
  }
}
##########################
## Private App Subnet - 2 ##
##########################
resource "aws_subnet" "private-app-subnet-2" {
  vpc_id                  = aws_vpc.vpc_01.id
  cidr_block              = var.private-app-subnet-2-cidr
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private APP subnet -2"
  }
}
##########################
## Private DB Subnet -1 ##
##########################
resource "aws_subnet" "private-db-subnet-1" {
  vpc_id                  = aws_vpc.vpc_01.id
  cidr_block              = var.private-db-subnet-1-cidr
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private DB subnet -1"
  }
}
##########################
## Private DB Subnet - 2 ##
##########################
resource "aws_subnet" "private-db-subnet-2" {
  vpc_id                  = aws_vpc.vpc_01.id
  cidr_block              = var.private-db-subnet-2-cidr
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private DB subnet -2"
  }
}
##########################
######  NAT Gateway ######
##########################
resource "aws_eip" "eip_nat" {
    vpc = true
 tags = {
      Name = eip1
   }
}

resource "aws_nat_gateway" "nat_1" {
  allocation_id = aws_eip.eip_nat.id
  subnet_id = aws_subnet.public-web-subnet-2.id
  tags = {
      Name = nat1
   }
}
##########################
## Private route table ##
##########################
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.vpc_01.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1.id
  }
  tags = {
    Name = "Private Route table"
  }
}
##########################
### Route Assoc for App tier ##
##########################
resource "aws_route_table_association" "nat_route_1" {
  subnet_id      = aws_subnet.private-app-subnet-1.id
  route_table_id = aws_route_table.private-route-table.id
}
resource "aws_route_table_association" "nat_route_2" {
  subnet_id      = aws_subnet.private-app-subnet-2.id
  route_table_id = aws_route_table.private-route-table.id
}
##########################
### Route Assoc for DB tier ##
##########################
resource "aws_route_table_association" "nat_route_db_1" {
  subnet_id      = aws_subnet.private-db-subnet-1.id
  route_table_id = aws_route_table.private-route-table.id
}
resource "aws_route_table_association" "nat_route_db_2" {
  subnet_id      = aws_subnet.private-db-subnet-2.id
  route_table_id = aws_route_table.private-route-table.id
}
##########################
### SG Application Load Balancer ##
##########################
resource "aws_security_group" "alb-security-group" {
  name        = "ALB-Security_Group"
  description = "Allow http/https traffic from port 80/443"
  vpc_id      = aws_vpc.vpc_01.id

  ingress {
    description     = "http access"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
 ingress {
    description     = "http access"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ALB-SG"
  }
}
##########################
### SG Application Tier | Server ##
##########################
resource "aws_security_group" "ssh-security-group" {
  name        = "Appserver_access"
  description = "Allow http/https traffic from port 22"
  vpc_id      = aws_vpc.vpc_01.id

  ingress {
    description     = "http access"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["${var.ssh-locate}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "App tier-SG"
  }
}

##########################
### SG Presentation tier ##
##########################
resource "aws_security_group" "webserver-security-group" {
  name        = "Webserver-Security_Group"
  description = "Allow http/https traffic from port 80/443 via alb & ssh via ssh sg"
  vpc_id      = aws_vpc.vpc_01.id

  ingress {
    description     = "http access"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.alb-security-group.id}"]
  }
 ingress {
    description     = "http access"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = ["${aws_security_group.alb-security-group.id}"]
  }
 ingress {
    description     = "http access"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ssh-security-group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web_Sever-SG"
  }
}

##########################
### SG Database tier ##
##########################
resource "aws_security_group" "database-security-group" {
  name        = "Database-Security_Group"
  description = "Allow http/https  MYSQL traffic from port on 3306"
  vpc_id      = aws_vpc.vpc_01.id

  ingress {
    description     = "MySQL access"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.webserver-security-group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Database_Sever-SG"
  }
}

##########################
### EC2 instance web tier ##
##########################
resource "aws_instance" "PublicWebTemplate" {
  ami                    = "ami-0d5eff06f840b45e9"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.webserver-security-group.id]
  subnet_id              = aws_subnet.public-web-subnet-1.id
  key_name               = "source_key"
  user_data              = file("install_apache.sh")
  

  tags = {
    Name = "Web Server-asg"
  }

##########################
### EC2 instance App tier ##
##########################

resource "aws_instance" "private-app-template" {
  ami                    = "ami-0d5eff06f840b45e9"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ssh-security-group.id]
  subnet_id              = aws_subnet.private-app-subnet-1.id
  key_name               = "source_key"

  tags = {
    Name = "App Server-asg"
  }

##########################
### ASG for Web | Presentation tier ##
##########################
resource "aws_launch_template" "auto-scaling-group" {
  name_prefix            = "auto-scaling-group"
  ami                    = "ami-0d5eff06f840b45e9"
  instance_type          = "t2.micro"
  key_name               = "source_key"
  user_data              = file("install_apache.sh")

  network interfaces {
  vpc_security_group_ids = [aws_security_group.webserver-security-group.id]
  subnet_id              = aws_subnet.public-web-subnet-1.id
  }
  
resource "aws_autoscaling_group" "asg-1" {
  availability_zones = ["us-east-1a"]
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1

  launch_template {
   id         = aws_launch_template.auto-scaling-group.id
   version    = "$Latest"
  } 
}

##########################
### ASG for App tier ##
##########################
resource "aws_launch_template" "auto-scaling-group-private" {
  name_prefix            = "auto-scaling-group-private"
  ami                    = "ami-0d5eff06f840b45e9"
  instance_type          = "t2.micro"
  key_name               = "source_key"

  network interfaces {
  vpc_security_group_ids = [aws_security_group.ssh-security-group.id]
  subnet_id              = aws_subnet.private-app-subnet-1.id
  }
  
resource "aws_autoscaling_group" "asg-2" {
  availability_zones = ["us-east-1a"]
  desired_capacity   = 1
  max_size           = 2
  min_size           = 1

  launch_template {
   id         = aws_launch_template.auto-scaling-group-private.id
   version    = "$Latest"
  } 
}
##########################
### ASG for App tier ##
##########################
resource "aws_lb" "application-load-balancer" {
  name               = "web-external-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-security-group.id]
  subnets            = [aws_subnet.public-web-subnet-1.id, aws_subnet.public-web-subnet-2.id]
  enable_deletion_protection = false

  tags = {
    Name = "App Load-Balancer"  
  }
}

resource "aws_lb_target_group" "alb_target_group" {
  name     = "Appbalancer_tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_01.id
}

resource "aws_lb_target_group_attachment" "web-attachment" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = aws_instance.PublicWebTemplate.id
  port             = 80

}

resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.application-load-balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
   
    redirect {
      port = 443
      protocol = "HTTPS"
      status_code = "HTTP_301" 
    }
  }
}

##########################
### DB Subnet-Group ##
##########################
resource "aws_db_subnet_group" "database-subnet-group" {
  name       = "database subnets"
  subnet_ids = [aws_subnet.private-db-subnet-1.id, aws_subnet.private-db-subnet-2.id]

  tags = {
    Name = "DB subnet group"
  }
}

##########################
### DB Instance   ##
##########################

resource "aws_db_instance" "database-instance" {
  allocated_storage      = 10
  db_subnet_group_name   = aws_db_subnet_group.database-subnet-group.id
  engine                 = "mysql"
  engine_version         = "8.0.28"
  instance_class         = var.database-instance-class
  multi_az               = var.multi-az-deployment
  name                   = "mydb"
  username               = "username"
  password               = "password"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.database-security-group.id]
}
##########################
### Load Balancer DNS   ##
##########################

output "lb_dns_name" {
  description = "DNS name of the load balancer"
  value = "${aws_lb.application-load-balancer.dns_name}"
}
