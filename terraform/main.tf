provider "aws" {
  region = "us-east-1"  # Escolha a região onde deseja lançar a instância
}


# Gerando uma nova Key Pair
resource "aws_key_pair" "nextwork_keypair" {
  key_name   = "nextwork-keypair"  # Nome que será dado ao Key Pair
  public_key = tls_private_key.generated_key.public_key_openssh  # Associando a chave pública gerada
}

# Gerando a chave privada com o Terraform
resource "tls_private_key" "generated_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Salvando a chave privada em um arquivo local
resource "local_file" "private_key" {
  content  = tls_private_key.generated_key.private_key_pem
  filename = "${path.module}/nextwork-keypair.pem"  # Nome do arquivo onde a chave privada será salva
}


# Security Group for SSH Access
resource "aws_security_group" "ssh_access" {
  name        = "ssh-access"
  description = "Allow SSH access from a specific IP"

  ingress {
    description = "SSH access from specific IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["172.31.21.189/32"]  # Allows access from your IP only
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allows all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh-access"
  }
}




# Criando a Instância EC2
resource "aws_instance" "nextwork_devops" {
  ami           = "ami-063d43db0594b521b"  # Obtém o ID da AMI do Amazon Linux 2023
  instance_type = "t2.micro"  # Tipo da instância (ajuste conforme necessário)
  
  key_name = aws_key_pair.nextwork_keypair.key_name  # Nome do Key Pair
  
  vpc_security_group_ids = [aws_security_group.ssh_access.id]  # Attach the security group

  tags = {
    Name = "nextwork-devops-vick"
  }
}
