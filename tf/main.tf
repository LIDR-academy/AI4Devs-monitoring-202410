terraform {
  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Configuración del proveedor de AWS
provider "aws" {
  region = "us-east-1"
}

# Configuración del proveedor de Datadog
provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = "https://api.us5.datadoghq.com"
}

# Variables de entorno para las claves de Datadog
variable "datadog_api_key" {
  description = "API Key para Datadog"
  type        = string
}

variable "datadog_app_key" {
  description = "App Key para Datadog"
  type        = string
}

# Política de IAM para permitir a Datadog acceder a CloudWatch
resource "aws_iam_policy" "datadog_policy" {
  name        = "DatadogPolicy"
  description = "Política para permitir a Datadog acceder a CloudWatch"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "cloudwatch:GetMetricData",
          "cloudwatch:ListMetrics",
          "ec2:DescribeInstances",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "tag:GetResources",
          "tag:GetTagKeys",
          "tag:GetTagValues"
        ],
        "Resource": "*"
      }
    ]
  })
}

# Obtener los nombres de las instancias EC2 automáticamente
data "aws_instances" "all" {
  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}
