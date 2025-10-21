resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true


  tags = {
    Name = var.vpc-name
    Env  = var.env
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name                                          = var.igw-name
    Env                                           = var.env
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
  depends_on = [aws_vpc.vpc]
}

resource "aws_subnet" "public-subnet" {
  count                   = var.pub-subnet-count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.pub-cidr-block, count.index)
  availability_zone       = element(var.pub-availability_zone, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name                                          = "${var.pub-subnet-name}-${count.index + 1}"
    Env                                           = var.env
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "kubernetes.io/role/elb"                      = 1
  }
  depends_on = [aws_vpc.vpc]
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.public-rt-name
    Env  = var.env
  }

  depends_on = [aws_vpc.vpc, aws_internet_gateway.igw]
}

resource "aws_route_table_association" "pub-route-association" {
  count          = var.pub-subnet-count
  route_table_id = aws_route_table.public-rt.id
  subnet_id      = aws_subnet.public-subnet[count.index].id

  depends_on = [aws_vpc.vpc, aws_subnet.public-subnet, aws_route_table.public-rt]
}

resource "aws_subnet" "pri-subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = var.pri-subnet-count
  cidr_block              = element(var.pri-cidr-block, count.index)
  availability_zone       = element(var.pri-availability_zone, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name                                          = "${var.pri-subnet-name}-${count.index + 1}"
    Env                                           = var.env
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "kubernetes.io/role/elb"                      = 1
  }
  depends_on = [aws_vpc.vpc]
}

resource "aws_eip" "ngw-eip" {
  domain = "vpc"
  tags = {
    Name = var.eip-name
  }
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "ngw" {
  subnet_id     = aws_subnet.public-subnet[0].id
  allocation_id = aws_eip.ngw-eip.id
  tags = {
    Name = var.ngw-name
  }

  depends_on = [aws_internet_gateway.igw, aws_eip.ngw-eip]
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }
  tags = {
    Name = var.private-rt-name
    Env  = var.env
  }
  depends_on = [aws_nat_gateway.ngw, aws_vpc.vpc]
}

resource "aws_route_table_association" "private-route-association" {
  count          = var.pri-subnet-count
  route_table_id = aws_route_table.private-rt.id
  subnet_id      = aws_subnet.pri-subnet[count.index].id
  depends_on     = [aws_vpc.vpc, aws_subnet.pri-subnet, aws_route_table.private-rt]
}

resource "aws_security_group" "eks-cluster-sg" {
  name        = var.eks-sg
  description = "Allow 443 from jump server"
  vpc_id      = aws_vpc.vpc.id
  tags = {
    Name = var.eks-sg
  }

  depends_on = [aws_vpc.vpc]
}

resource "aws_vpc_security_group_ingress_rule" "eks-cluster-sg-ingress" {
  security_group_id = aws_security_group.eks-cluster-sg.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = aws_vpc.vpc.cidr_block

  depends_on = [aws_security_group.eks-cluster-sg]
}

resource "aws_vpc_security_group_egress_rule" "eks-cluster-sg-egress" {
  security_group_id = aws_security_group.eks-cluster-sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

