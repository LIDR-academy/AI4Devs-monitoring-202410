variable "aws_region" {
  description = "La región de AWS para desplegar recursos"
  type        = string
}

variable "subnet_id" {
  description = "ID de la subred para las instancias EC2"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

variable "subnet_cidr_block" {
  description = "CIDR block para la subred"
  type        = string
}
