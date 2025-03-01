#!/bin/bash

# Configurar registro detallado para depuración
set -x
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "Iniciando script de configuración del frontend: $(date)"

# Instalar dependencias necesarias
echo "Instalando dependencias..."
yum update -y
# Usar comillas simples para evitar que Terraform interprete las variables
yum install -y docker unzip awscli || echo "Instalación básica completada"
echo "Intentando instalar headers del kernel..."
yum install -y kernel-devel kernel-headers || echo "No se pudieron instalar los headers del kernel"

# Configurar br_netfilter para Docker
echo "Configurando br_netfilter para Docker..."
modprobe br_netfilter || echo "No se pudo cargar br_netfilter"
echo 'net.bridge.bridge-nf-call-iptables=1' | tee -a /etc/sysctl.conf
sysctl -p

# Asegurarse de que Docker esté instalado correctamente
if ! command -v docker &> /dev/null; then
    echo "Docker no se instaló correctamente. Intentando instalar manualmente..."
    amazon-linux-extras install docker -y
    if ! command -v docker &> /dev/null; then
        echo "ERROR: No se pudo instalar Docker. Abortando."
        exit 1
    fi
fi

# Descargar el archivo .env desde S3
echo "Descargando archivo .env desde S3..."
aws s3 cp s3://lti-project-code-bucket-jlso/.env /home/ec2-user/.env || echo "No se pudo descargar el archivo .env"

# Cargar variables desde el archivo .env
if [ -f /home/ec2-user/.env ]; then
  export $(grep -v '^#' /home/ec2-user/.env | xargs)
  echo "Variables de entorno cargadas desde .env"
else
  echo "Archivo .env no encontrado, usando valores por defecto"
  # Valores por defecto en caso de que no se encuentre el archivo .env
  export DD_AGENT_MAJOR_VERSION=7
  export DD_API_KEY="<YOUR-API-KEY>"
  export DD_SITE="datadoghq.com"
fi

# Configuración avanzada del agente Datadog
echo "Configurando agente Datadog..."
export DD_AGENT_MAJOR_VERSION=7
export DD_API_KEY="<YOUR-API-KEY>"
export DD_SITE="datadoghq.com"
export DD_HOSTNAME="frontend-$(hostname)"
export DD_TAGS="service:frontend,environment:production,team:sre,application:lti-project"
export DD_APM_ENABLED=true
export DD_LOGS_ENABLED=true
export DD_PROCESS_AGENT_ENABLED=true
export DD_DOCKER_ENABLED=true
export DD_COLLECT_EC2_TAGS=true

# Instalar el agente Datadog
echo "Instalando agente Datadog..."
DD_API_KEY="<YOUR-API-KEY>" DD_SITE="datadoghq.com" DD_AGENT_MAJOR_VERSION=7 bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)" || {
  echo "Error al instalar el agente Datadog. Reintentando..."
  DD_API_KEY="<YOUR-API-KEY>" DD_SITE="datadoghq.com" DD_AGENT_MAJOR_VERSION=7 bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"
}

# Verificar que el agente se instaló correctamente
if ! command -v datadog-agent &> /dev/null; then
  echo "ERROR: No se pudo instalar el agente Datadog"
else
  echo "Agente Datadog instalado correctamente"
fi

# Asegurarse de que el directorio de configuración existe
mkdir -p /etc/datadog-agent/

# Crear archivo datadog.yaml básico si no existe
if [ ! -f /etc/datadog-agent/datadog.yaml ]; then
  echo "Creando archivo datadog.yaml básico..."
  HOSTNAME=$(hostname)
  cat > /etc/datadog-agent/datadog.yaml << EOF
api_key: "<YOUR-API-KEY>"
site: "datadoghq.com"
hostname: "frontend-$HOSTNAME"
tags:
  - service:frontend
  - environment:production
  - team:sre
  - application:lti-project
logs_enabled: true
apm_config:
  enabled: true
process_config:
  enabled: true
collect_ec2_tags: true

# System probe configuration
system_probe_config:
  enabled: true
EOF
fi

# Configurar System Probe
echo "Configurando System Probe..."
cat > /etc/datadog-agent/system-probe.yaml << EOF
system_probe_config:
  enabled: true
  sysprobe_socket: /opt/datadog-agent/run/sysprobe.sock

network_config:
  enabled: true
EOF

# Configurar check de CPU
echo "Configurando check de CPU..."
mkdir -p /etc/datadog-agent/conf.d/cpu.d/
cat > /etc/datadog-agent/conf.d/cpu.d/conf.yaml << EOF
init_config:

instances:
  - {}
EOF

# Configurar check de System Core
echo "Configurando check de System Core..."
mkdir -p /etc/datadog-agent/conf.d/system_core.d/
cat > /etc/datadog-agent/conf.d/system_core.d/conf.yaml << EOF
init_config:

instances:
  - {}
EOF

# Configurar integraciones de Datadog
echo "Configurando integración de Docker para Datadog..."
mkdir -p /etc/datadog-agent/conf.d/docker.d/
cat > /etc/datadog-agent/conf.d/docker.d/conf.yaml << EOF
init_config:

instances:
  - url: "unix://var/run/docker.sock"
    collect_container_size: true
    collect_container_count: true
    collect_volume_count: true
    collect_images_stats: true
    collect_exit_codes: true
    tags:
      - "service:frontend"
EOF

# Corregir permisos
echo "Corrigiendo permisos de los archivos de configuración..."
chown -R dd-agent:dd-agent /etc/datadog-agent/
chmod -R 755 /etc/datadog-agent/

# Reiniciar el agente para aplicar la configuración
echo "Reiniciando agente Datadog..."
systemctl restart datadog-agent
systemctl enable datadog-agent

# Iniciar y habilitar System Probe
echo "Iniciando System Probe..."
systemctl restart datadog-agent-sysprobe || systemctl start datadog-agent-sysprobe
systemctl enable datadog-agent-sysprobe || echo "No se pudo habilitar datadog-agent-sysprobe"

# Iniciar y habilitar Process Agent
echo "Iniciando Process Agent..."
systemctl restart datadog-agent-process || systemctl start datadog-agent-process
systemctl enable datadog-agent-process || echo "No se pudo habilitar datadog-agent-process"

# Verificar que el agente Datadog se inició correctamente
echo "Verificando que el agente Datadog se inició correctamente..."
for i in {1..5}; do
  if systemctl is-active datadog-agent >/dev/null 2>&1; then
    echo "Agente Datadog se ha iniciado correctamente"
    break
  else
    echo "Esperando a que el agente Datadog se inicie (intento $i/5)..."
    sleep 10
    systemctl restart datadog-agent
  fi
  
  if [ $i -eq 5 ]; then
    echo "ADVERTENCIA: No se pudo iniciar el agente Datadog después de 5 intentos"
    systemctl status datadog-agent
    # No salimos con error para permitir que el resto del script continúe
  fi
done

# Iniciar y habilitar el servicio de Docker
echo "Iniciando el servicio Docker..."
systemctl start docker
systemctl enable docker

# Verificar que Docker esté en funcionamiento
echo "Verificando que Docker esté en funcionamiento..."
for i in {1..5}; do
  if systemctl is-active docker >/dev/null 2>&1; then
    echo "Docker se ha iniciado correctamente"
    break
  else
    echo "Esperando a que Docker se inicie (intento $i/5)..."
    sleep 10
    systemctl start docker
  fi
  
  if [ $i -eq 5 ]; then
    echo "ERROR: No se pudo iniciar Docker después de 5 intentos"
    systemctl status docker
    exit 1
  fi
done

# Asegurarse de que el usuario ec2-user pueda usar Docker sin sudo
echo "Configurando permisos de Docker para ec2-user..."
usermod -aG docker ec2-user
# Reiniciar Docker para aplicar los cambios de grupo
systemctl restart docker
sleep 5

# Descargar y descomprimir el archivo frontend.zip desde S3
echo "Descargando y descomprimiendo el código del frontend..."
aws s3 cp s3://lti-project-code-bucket-jlso/frontend.zip /home/ec2-user/frontend.zip || {
    echo "ERROR: No se pudo descargar frontend.zip desde S3"
    exit 1
}
unzip -o /home/ec2-user/frontend.zip -d /home/ec2-user/ || {
    echo "ERROR: No se pudo descomprimir frontend.zip"
    exit 1
}

# Verificar que el directorio del frontend existe
if [ ! -d "/home/ec2-user/frontend" ]; then
    echo "ERROR: No se encontró el directorio /home/ec2-user/frontend después de descomprimir"
    ls -la /home/ec2-user/
    exit 1
fi

# Construir la imagen Docker para el frontend
echo "Construyendo imagen Docker para el frontend..."
cd /home/ec2-user/frontend
docker build -t lti-frontend . || {
    echo "ERROR: Falló la construcción de la imagen Docker"
    exit 1
}

# Verificar si ya existe un contenedor con el mismo nombre
echo "Verificando si ya existe un contenedor lti-frontend..."
if docker ps -a | grep lti-frontend; then
    echo "Eliminando contenedor existente lti-frontend..."
    docker stop lti-frontend || true
    docker rm lti-frontend || true
fi

# Ejecutar el contenedor Docker con etiquetas para Datadog
echo "Iniciando contenedor Docker para el frontend..."
INSTANCE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
docker run -d -p 3000:3000 \
  --name lti-frontend \
  -e DD_AGENT_HOST=$INSTANCE_IP \
  -e DD_ENV=production \
  -e DD_SERVICE=frontend \
  -e DD_VERSION=1.0 \
  lti-frontend

# Verificar que el contenedor se haya iniciado correctamente
echo "Verificando que el contenedor se haya iniciado correctamente..."
sleep 10  # Aumentamos el tiempo de espera para dar más tiempo al contenedor para iniciar
MAX_RETRIES=3
for i in $(seq 1 $MAX_RETRIES); do
  if docker ps | grep lti-frontend; then
    echo "Contenedor lti-frontend iniciado correctamente"
    # Verificar que el servicio responde
    echo "Verificando que el servicio responde..."
    sleep 5
    if curl -s http://localhost:3000 > /dev/null; then
      echo "El servicio frontend responde correctamente"
      break
    else
      echo "El servicio no responde en el puerto 3000, pero el contenedor está en ejecución"
      if [ $i -eq $MAX_RETRIES ]; then
        echo "ADVERTENCIA: El servicio no responde después de $MAX_RETRIES intentos"
        docker logs lti-frontend
      else
        echo "Reintentando en 10 segundos... (intento $i/$MAX_RETRIES)"
        sleep 10
      fi
    fi
  else
    echo "ERROR: No se pudo iniciar el contenedor lti-frontend (intento $i/$MAX_RETRIES)"
    docker logs lti-frontend
    echo "Estado de Docker:"
    systemctl status docker
    echo "Imágenes disponibles:"
    docker images
    echo "Todos los contenedores:"
    docker ps -a
    
    if [ $i -eq $MAX_RETRIES ]; then
      echo "ERROR: No se pudo iniciar el contenedor después de $MAX_RETRIES intentos"
    else
      echo "Reintentando iniciar el contenedor... (intento $i/$MAX_RETRIES)"
      docker run -d -p 3000:3000 \
        --name lti-frontend \
        -e DD_AGENT_HOST=$INSTANCE_IP \
        -e DD_ENV=production \
        -e DD_SERVICE=frontend \
        -e DD_VERSION=1.0 \
        lti-frontend
      sleep 10
    fi
  fi
done

# Verificar la integración con Datadog
echo "Verificando integración con Datadog..."
if systemctl is-active datadog-agent >/dev/null 2>&1; then
  echo "Agente Datadog está activo, verificando estado..."
  datadog-agent status || echo "No se pudo obtener el estado del agente Datadog"
  
  # Verificar integración con Docker
  echo "Verificando integración de Datadog con Docker..."
  datadog-agent status | grep -A 10 docker || echo "No se encontró información sobre la integración con Docker"
else
  echo "ADVERTENCIA: El agente Datadog no está activo"
fi

# Timestamp to force update
echo "Configuración completada: $(date)"
echo "Timestamp: ${timestamp}"
