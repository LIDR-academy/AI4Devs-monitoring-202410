# Configuración de Monitorización con Datadog para AWS EC2

Este proyecto configura la monitorización de instancias EC2 en AWS utilizando Datadog a través de Terraform.

## Estructura del Proyecto

El proyecto utiliza Terraform para aprovisionar y gestionar infraestructura en AWS, incluyendo:

- Bucket S3 para almacenar archivos de código
- Instancias EC2 para frontend y backend
- Grupos de seguridad
- Políticas IAM
- Dashboard de Datadog para monitoreo

## Archivos Principales

- `main.tf`: Configuración principal de Terraform y proveedores
- `s3.tf`: Configuración del bucket S3 y objetos
- `ec2.tf`: Configuración de instancias EC2
- `security_groups.tf`: Configuración de grupos de seguridad
- `iam.tf`: Configuración de políticas y roles IAM
- `scripts/`: Scripts de inicialización para instancias EC2

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

## Retos Enfrentados y Soluciones

### 1. Conflictos de Nombres de Recursos

**Problema**: Al intentar aplicar la configuración, se encontraron errores porque algunos recursos ya existían con los mismos nombres en AWS.

**Solución**: Se modificaron los nombres de los recursos añadiendo un sufijo único (`-jlso`) para evitar conflictos:

```terraform
# Antes
resource "aws_iam_policy" "datadog_policy" {
  name = "DatadogPolicy"
  # ...
}

# Después
resource "aws_iam_policy" "datadog_policy" {
  name = "DatadogPolicy-jlso"
  # ...
}
```

Recursos modificados:

- Política IAM: `DatadogPolicy-jlso`
- Grupos de seguridad: `lti-project-backend-sg-jlso` y `lti-project-frontend-sg-jlso`
- Bucket S3: `lti-project-code-bucket-jlso`

### 2. Problemas con ACL del Bucket S3

**Problema**: Error al crear el ACL del bucket S3 debido a que los buckets S3 modernos no permiten ACLs por defecto.

```
Error: error creating S3 bucket ACL: AccessControlListNotSupported: The bucket does not allow ACLs
```

**Solución**: Se reemplazó el recurso `aws_s3_bucket_acl` por `aws_s3_bucket_ownership_controls` para configurar la propiedad de objetos:

```terraform
resource "aws_s3_bucket_ownership_controls" "code_bucket_ownership" {
  bucket = aws_s3_bucket.code_bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
```

### 3. Recursos Obsoletos en el Estado de Terraform

**Problema**: Errores al intentar aplicar cambios debido a recursos obsoletos en el estado de Terraform.

**Solución**: Se limpiaron los recursos obsoletos del estado:

```bash
terraform state rm aws_s3_bucket_object.backend_zip aws_s3_bucket_object.frontend_zip
```

Y se actualizaron a los recursos modernos:

```terraform
resource "aws_s3_object" "backend_zip" {
  # Configuración actualizada
}
```

### 4. Manejo de Información Sensible

**Problema**: Claves API y secretos hardcodeados en scripts y configuraciones.

**Solución**:

1. Se marcaron las variables sensibles en Terraform:

   ```terraform
   variable "datadog_api_key" {
     sensitive = true
     # ...
   }
   ```

2. Se excluyeron archivos sensibles del control de versiones en `.gitignore`:

   ```
   # Scripts con información sensible
   tf/scripts/backend_user_data.sh
   tf/scripts/frontend_user_data.sh

   # Archivos de estado y variables
   *.tfstate
   *.tfstate.*
   *.tfvars
   .env
   ```

## Proceso de Despliegue

Para desplegar esta infraestructura:

1. Asegúrate de tener las credenciales de AWS configuradas
2. Crea un archivo `.env` con las variables necesarias
3. Inicializa Terraform:
   ```bash
   cd tf
   terraform init
   ```
4. Planifica los cambios:
   ```bash
   terraform plan
   ```
5. Aplica la configuración:
   ```bash
   terraform apply
   ```

## Resumen de retos enfrentados

- Entender la configuración de terraform
- Que hay que tener cuidado con los nombres de los recursos, ya que deben ser únicos en todo aws
- Problemas con ACL del Bucket S3
- Recursos obsoletos en el estado de Terraform
- Manejo de información sensible
- Se implementó un enfoque de primero hacer que lo que ya estaba configurado funcione, para luego empezar a configurar el monitoreo con datadog, el cual será el siguiente paso.
