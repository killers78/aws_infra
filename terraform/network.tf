
# Criando a VPC
resource "aws_vpc" "lucianocastroVPC" {
  cidr_block = "10.0.0.0/16"
}

# Criando as subnets

resource "aws_subnet" "private01" {
  vpc_id            = aws_vpc.lucianocastroVPC.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a" 
  tags = {
    Name = "Private"
  }
}

resource "aws_subnet" "nat01" {
  vpc_id            = aws_vpc.lucianocastroVPC.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"  
  tags = {
    Name = "Nat"
  }
}

resource "aws_subnet" "public01" {
  vpc_id            = aws_vpc.lucianocastroVPC.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1c" 
  tags = {
    Name = "Public"
  }
}

# Criando o Internet Gateway
resource "aws_internet_gateway" "lucianocastroIGW" {
  vpc_id = aws_vpc.lucianocastroVPC.id
}

# Criando o NAT Gateway
resource "aws_nat_gateway" "lucianocastroNGW" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public01.id

    tags = {
    Name = "NAT GW"
    }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.lucianocastroIGW]
}


# Associando um EIP ao NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
}


# Alterando a tabela de rotas da rede nat01 para apontar para o NAT Gateway
resource "aws_route_table_association" "nat01" {
  subnet_id      = aws_subnet.nat01.id
  route_table_id = aws_route_table.nat.id
}

# Alterando a tabela de rotas da rede public01 para apontar para o IGW Gateway
resource "aws_route_table_association" "public01" {
  subnet_id      = aws_subnet.public01.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "nat" {
  vpc_id = aws_vpc.lucianocastroVPC.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.lucianocastroNGW.id
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.lucianocastroVPC.id

  route {
    cidr_block     = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lucianocastroIGW.id
  }
}