provider "aws" {
  region = var.aws_region
}

# 1. VPC を作成
resource "aws_vpc" "demo" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "demo-vpc"
  }
}

# 2. パブリックサブネットを作成
resource "aws_subnet" "demo_public" {
  vpc_id                  = aws_vpc.demo.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "demo-public-subnet"
  }
}

# 3. インターネットゲートウェイ作成＆アタッチ
resource "aws_internet_gateway" "demo_igw" {
  vpc_id = aws_vpc.demo.id

  tags = {
    Name = "demo-igw"
  }
}

# 4. メインルートテーブルに IGW をルーティング
resource "aws_route_table" "demo_rt" {
  vpc_id = aws_vpc.demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo_igw.id
  }

  tags = {
    Name = "demo-rt"
  }
}

resource "aws_route_table_association" "demo_rta" {
  subnet_id      = aws_subnet.demo_public.id
  route_table_id = aws_route_table.demo_rt.id
}

# 5. セキュリティグループ（SSH と HTTP 通信を許可）
resource "aws_security_group" "demo_sg" {
  name        = "demo-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.demo.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "demo-sg"
  }
}

# 6. EC2 インスタンスを起動（Amazon Linux 2, t3.micro）
resource "aws_instance" "demo_ec2" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.demo_public.id
  vpc_security_group_ids      = [aws_security_group.demo_sg.id]
  associate_public_ip_address = true
  key_name                    = var.ec2_key_name

  tags = {
    Name = "demo-ec2"
  }
}

# 7. Amazon Linux 2 の最新 AMI を取得（東京リージョン）
data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  owners = ["amazon"]
}
