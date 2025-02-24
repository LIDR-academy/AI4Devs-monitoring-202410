#!/bin/bash
# Instalar el agente de Datadog
DD_AGENT_MAJOR_VERSION=7 DD_API_KEY="${datadog_api_key}" DD_SITE="us5.datadoghq.com" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

# Configurar tags personalizados
echo "tags:" >> /etc/datadog-agent/datadog.yaml
echo "  - env:production" >> /etc/datadog-agent/datadog.yaml
echo "  - service:frontend" >> /etc/datadog-agent/datadog.yaml

# Reiniciar el agente
systemctl restart datadog-agent

yum update -y
yum install -y docker

# Iniciar el servicio de Docker
service docker start

# Descargar y descomprimir el archivo frontend.zip desde S3
aws s3 cp s3://lti-project-code-bucket/frontend.zip /home/ec2-user/frontend.zip
unzip /home/ec2-user/frontend.zip -d /home/ec2-user/

# Construir la imagen Docker para el frontend
cd /home/ec2-user/frontend
docker build -t lti-frontend .

# Ejecutar el contenedor Docker
docker run -d -p 80:80 lti-frontend

# Timestamp to force update
echo "Timestamp: ${timestamp}"
