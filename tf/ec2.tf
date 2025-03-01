data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Calcular hash de los scripts para forzar la recreación cuando cambien
locals {
  backend_user_data_hash = md5(file("scripts/backend_user_data.sh"))
  frontend_user_data_hash = md5(file("scripts/frontend_user_data.sh"))
}

resource "aws_instance" "backend" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  user_data              = templatefile("scripts/backend_user_data.sh", { timestamp = timestamp() })
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  
  # Forzar recreación cuando cambia el script
  user_data_replace_on_change = true
  
  tags = {
    Name = "lti-project-backend"
    Datadog = "true"
    ScriptHash = local.backend_user_data_hash
  }
}

resource "aws_instance" "frontend" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.medium"
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  user_data              = templatefile("scripts/frontend_user_data.sh", { timestamp = timestamp() })
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]
  
  # Forzar recreación cuando cambia el script
  user_data_replace_on_change = true
  
  tags = {
    Name = "lti-project-frontend"
    Datadog = "true"
    ScriptHash = local.frontend_user_data_hash
  }
}

output "backend_instance_id" {
  value = aws_instance.backend.id
}

output "frontend_instance_id" {
  value = aws_instance.frontend.id
}

output "backend_public_ip" {
  value = aws_instance.backend.public_ip
}

output "frontend_public_ip" {
  value = aws_instance.frontend.public_ip
}
