# Configuración de Terraform para Monitoreo con Datadog

Este documento describe la configuración de Terraform utilizada en este proyecto, los retos enfrentados durante la implementación y las soluciones aplicadas.

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
