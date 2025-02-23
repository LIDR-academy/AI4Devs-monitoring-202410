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

resource "aws_instance" "backend" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  user_data              = templatefile("${path.module}/templates/backend_user_data.tpl", {
    datadog_api_key = var.datadog_api_key
    timestamp       = timestamp()
  })
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  subnet_id              = var.subnet_id
  tags = {
    Name = "lti-project-backend"
    Datadog     = "true"
  }
}

resource "aws_instance" "frontend" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.medium"
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  user_data              = templatefile("${path.module}/templates/frontend_user_data.tpl", {
    datadog_api_key = var.datadog_api_key
    timestamp       = timestamp()
  })
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]
  subnet_id              = var.subnet_id
  tags = {
    Name = "lti-project-frontend"
    Datadog     = "true"
  }
}

resource "aws_eip" "frontend_eip" {
  instance                  = aws_instance.frontend.id
  associate_with_private_ip = aws_instance.frontend.private_ip
}

resource "aws_eip" "backend_eip" {
  instance                  = aws_instance.backend.id
  associate_with_private_ip = aws_instance.backend.private_ip
}

output "backend_instance_id" {
  value = aws_instance.backend.id
}

output "frontend_instance_id" {
  value = aws_instance.frontend.id
}
