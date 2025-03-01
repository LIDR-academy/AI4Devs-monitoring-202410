# Configuración de Monitorización con Datadog para AWS EC2

Este proyecto configura la monitorización de instancias EC2 en AWS utilizando Datadog a través de Terraform.

## Estructura del Proyecto

- `main.tf`: Configuración principal de Terraform y proveedores
- `ec2.tf`: Definición de instancias EC2
- `s3.tf`: Configuración del bucket S3 y objetos
- `security_groups.tf`: Definición de grupos de seguridad
- `iam.tf`: Configuración de roles y políticas IAM
- `monitors.tf`: Definición de monitores y alertas de Datadog
- `variables.tf`: Definición de variables para la configuración
- `scripts/`: Scripts de inicialización para instancias EC2

## Componentes de Monitorización

### 1. Integración de Datadog con AWS

Se ha configurado una política IAM que permite a Datadog acceder a métricas de CloudWatch y otros recursos de AWS. Esta política incluye permisos para:

- Acceso a métricas de CloudWatch
- Descripción de instancias EC2
- Acceso a logs
- Acceso a CloudTrail
- Acceso a AWS Health

### 2. Agente Datadog en Instancias EC2

El agente Datadog se instala automáticamente en las instancias EC2 a través de scripts de inicialización. La configuración incluye:

- Recopilación de métricas del sistema (CPU, memoria, disco, red)
- Recopilación de logs
- Monitorización de procesos
- Integración con Docker
- Recopilación de etiquetas EC2

### 3. Dashboard de Datadog

Se ha creado un dashboard completo en Datadog que incluye:

- Métricas de CPU (utilización, créditos)
- Métricas de memoria
- Métricas de red (tráfico entrante/saliente, paquetes)
- Métricas de disco (lectura/escritura, uso)
- Lista de las instancias con mayor uso de CPU

### 4. Monitores y Alertas

Se han configurado varios monitores para alertar sobre problemas potenciales:

- Alta utilización de CPU (>80%)
- Alta utilización de memoria (>85%)
- Alto uso de disco (>85%)
- Instancias EC2 no disponibles
- Errores en logs de aplicación

## Requisitos

- Terraform >= 0.14
- Cuenta de AWS con permisos adecuados
- Cuenta de Datadog con API key y Application key

## Uso

1. Configura las variables de entorno o crea un archivo `.env` con las siguientes variables:

   ```
   TF_VAR_datadog_api_key=<tu_api_key>
   TF_VAR_datadog_app_key=<tu_app_key>
   ```

2. Inicializa Terraform:

   ```
   terraform init
   ```

3. Planifica los cambios:

   ```
   terraform plan
   ```

4. Aplica la configuración:
   ```
   terraform apply
   ```

## Personalización

Puedes personalizar la configuración modificando las variables en `variables.tf` o proporcionando valores diferentes al ejecutar `terraform apply`:

```
terraform apply -var="environment=staging" -var="team=devops"
```

## Consideraciones de Seguridad

- Las claves API de Datadog se manejan como variables sensibles
- Se recomienda utilizar AWS Secrets Manager o Parameter Store para almacenar secretos en producción
- Los scripts de inicialización obtienen las credenciales de forma segura desde un archivo `.env` almacenado en S3

## Mantenimiento

Para actualizar la configuración:

1. Modifica los archivos de Terraform según sea necesario
2. Ejecuta `terraform plan` para verificar los cambios
3. Ejecuta `terraform apply` para aplicar los cambios

## Troubleshooting

Si el agente Datadog no está enviando métricas:

1. Verifica que las instancias EC2 tengan acceso a Internet
2. Comprueba los logs del agente: `/var/log/datadog/agent.log`
3. Asegúrate de que la política IAM tenga los permisos correctos
4. Verifica que las claves API sean válidas
