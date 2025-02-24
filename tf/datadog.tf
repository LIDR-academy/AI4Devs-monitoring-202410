# Obtener la identidad actual de AWS
data "aws_caller_identity" "current" {}

# Mantener solo el rol IAM y sus políticas
resource "aws_iam_role" "datadog_integration" {
  name = "DatadogAWSIntegrationRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::464622532012:root"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = "6cc0198030fc4078ab176961142b6672"  # Usar el ID existente
          }
        }
      }
    ]
  })
}

# Adjuntar la política existente de Datadog al rol de integración
resource "aws_iam_role_policy_attachment" "datadog_policy_attachment" {
  role       = aws_iam_role.datadog_integration.name
  policy_arn = aws_iam_policy.datadog_policy.arn
}

# Crear el rol de IAM para las instancias EC2
resource "aws_iam_role" "ec2_role" {
  name = "EC2InstanceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Crear la política para acceso a S3
resource "aws_iam_role_policy" "s3_access" {
  name = "S3AccessPolicy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::lti-project-code-bucket-*",
          "arn:aws:s3:::lti-project-code-bucket-*/*"
        ]
      }
    ]
  })
}

# Crear el perfil de instancia
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2InstanceProfile"
  role = aws_iam_role.ec2_role.name
}
