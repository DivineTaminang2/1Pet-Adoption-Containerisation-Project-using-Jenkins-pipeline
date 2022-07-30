# Create VPC
resource "aws_vpc" "pacpjeu1_vpc" {
  cidr_block = "10.0.0.0/16"
}
# Public Subnet1
resource "aws_subnet" "pacpjeu1_pubsn1" {
  vpc_id     = aws_vpc.pacpjeu1_vpc.id
  cidr_block = "10.0.5.0/24"

  tags = {
    Name = "pacpjeu1_pubsn1"
  }
}
# Public Subnet2
resource "aws_subnet" "pacpjeu1_pubsn2" {
  vpc_id     = aws_vpc.pacpjeu1_vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "pacpjeu1_pubsn2"
  }
}
# Private Subnet1
resource "aws_subnet" "pacpjeu1_prvsn1" {
  vpc_id     = aws_vpc.pacpjeu1_vpc.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "pacpjeu1_prvsn1"
  }
}
# Private Subnet2
resource "aws_subnet" "pacpjeu1_prvsn2" {
  vpc_id     = aws_vpc.pacpjeu1_vpc.id
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "pacpjey1_prvsn2"
  }
}
# Internet Gateway
resource "aws_internet_gateway" "pacpjeu1_igw" {
  vpc_id = aws_vpc.pacpjeu1_vpc.id

  tags = {
    Name = "pacpjeu1_igw"
  }
}
# Natgateway
resource "aws_nat_gateway" "pacpjeu1_natgw" {
  allocation_id = aws_eip.pacpjeu1_eip.id 
  subnet_id = aws_subnet.pacpjeu1_pubsn1.id

  tags = {
    Name = "NATgw"
  }
}

# create Elastic IP
resource "aws_eip" "pacpjeu1_eip" {
  # instance = aws_instance.web.id
  vpc = true
}

# route public table
resource "aws_route_table" "pacpjeu1_pub_rtb" {
  vpc_id = aws_vpc.pacpjeu1_vpc.id

  route {
    gateway_id = aws_internet_gateway.pacpjeu1_igw.id
    cidr_block = "0.0.0.0/0"
  }
  tags = {
    Name = "pacpjeu1_pub_rtb"
  }
}



#  Public route tables association pubsn1

resource "aws_route_table_association" "pacpjeu1_pubsn1_rtb_asssociation" {
  subnet_id      = aws_subnet.pacpjeu1_pubsn1.id
  route_table_id = aws_route_table.pacpjeu1_pub_rtb.id
}

#  Public route tables association pubsn2

resource "aws_route_table_association" "pacpjeu1_pubsn2_rtb_asssociation" {
  subnet_id      = aws_subnet.pacpjeu1_pubsn2.id
  route_table_id = aws_route_table.pacpjeu1_pub_rtb.id
}



# create prv route tables 
resource "aws_route_table" "pacpjeu1_prv_rtb" {
  vpc_id = aws_vpc.pacpjeu1_vpc.id

  route {
    gateway_id = aws_nat_gateway.pacpjeu1_natgw.id
    cidr_block = "0.0.0.0/0"

  }

  tags = {
    Name = "pacpjeu1_prv_rtb"
  }
}
#  Private route tables association prvsn1
resource "aws_route_table_association" "pacpjeu1_prvsn1_rtb_asssociation" {
  subnet_id      = aws_subnet.pacpjeu1_prvsn1.id
  route_table_id = aws_route_table.pacpjeu1_prv_rtb.id

}
#  Private route tables association prvsn2
resource "aws_route_table_association" "pacpjeu1_prvsn2_rtb_asssociation" {
  subnet_id     = aws_subnet.pacpjeu1_prvsn2.id
  route_table_id = aws_route_table.pacpjeu1_prv_rtb.id

}


# Security groups- frontend
resource "aws_security_group" "pacpjeu1_fe_sg" {
  name        = "pacpjeu1_fe_sg"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.pacpjeu1_vpc.id


  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::0/0"]
  }

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "jenkins_server"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "Tomcat_server"
    from_port        = 8085
    to_port          = 8085
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "pacpjeu1_fe_sg"
  }
}
# Backend security -sg
resource "aws_security_group" "pacpjeu1_be_sg" {
  name        = "pacpjeu1_be_sg"
  description = "Allow outbound traffic"
  vpc_id      = aws_vpc.pacpjeu1_vpc.id

  ingress {
    description      = "RDS"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "pacpjeu1_be_sg"
  }
}

#  Create a subnet group
resource "aws_db_subnet_group" "pacpjeu1_subnetgp" {
  name       = "pacpjeueu1_prvsubnetgp"
  subnet_ids = [aws_subnet.pacpjeu1_prvsn1.id, aws_subnet.pacpjeu1_prvsn2.id]

  tags = {
    Name = "My DB subnet group-privatesubets"
  }
}
#  Create RDS Database
resource "aws_db_instance" "pacpjeu1_db" {
  allocated_storage = 10
  # identifier             = var.db_name
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = var.instance_class
  db_name                = var.db_name
  username               = var.user_name
  password               = var.db_password
  parameter_group_name   = "default.mysql5.7"
  multi_az               = true
  skip_final_snapshot    = true
  apply_immediately      = true
  db_subnet_group_name   = aws_db_subnet_group.pacpjeu1_subnetgp.id
  vpc_security_group_ids = [aws_security_group.pacpjeu1_be_sg.id]
}

# create Keypairs
resource "aws_key_pair" "pacpjeu1_keypairs" {
  key_name   = "pacpjeu1_keypairs"
  public_key = file(var.location-to-Keypairs)
}




# Jenkins

# Provision Jenkins Server
resource "aws_instance" "Jenkins_Server" {
  ami                         = var.jenkins_ami
  instance_type               = "t2.medium"
  key_name                    = "pacpjeu1_keypairs"
  subnet_id                   = aws_subnet.pacpjeu1_pubsn1.id
  vpc_security_group_ids      = [aws_security_group.pacpjeu1_fe_sg.id]
  associate_public_ip_address = true
  user_data                   = <<-EOF
#!/bin/bash
sudo yum update -y
sudo yum install wget -y
sudo yum install git -y
sudo yum install maven -y
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum upgrade -y
sudo yum install jenkins java-11-openjdk-devel -y --nobest
sudo yum install epel-release java-11-openjdk-devel
sudo systemctl daemon-reload
sudo systemctl start jenkins
sudo systemctl enable jenkins
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum update -y
sudo yum install docker-ce docker-ce-cli containerd.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
sudo usermod -aG docker jenkins
echo "license_key: eu01xx4fc443b5ef136bb617380505f93e08NRAL" | sudo tee -a /etc/newrelic-infra.yml
sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/el/7/x86_64/newrelic-infra.repo
sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'
sudo yum install newrelic-infra -y
sudo hostnamectl set-hostname Jenkins
EOF 
  tags = {
    Name = "Jenkins_Server"
  }
}

# Docker 


















# # Route53 [CORRECT NAMING CONVENTION]

# resource "aws_route53_zone" "PACPJP_zone_EU1" {
#   name = "divinedevs.com"
# }


# resource "aws_route53_record" "PACPJP_record_EU1" {
#   zone_id = aws_route53_zone.PACPJP_zone_EU1.zone_id
#   name    = "divinedevs.com"
#   type    = "A"
#   ttl     = "300"
#   records = [aws_eip.lb.public_ip]
# }