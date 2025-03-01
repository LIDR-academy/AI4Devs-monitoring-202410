# Prompts Utilizados para Configuración de Terraform con AWS y Datadog

Este documento recopila los prompts clave utilizados durante la configuración de Terraform para el proyecto de monitoreo con AWS y Datadog. Estos prompts pueden servir como referencia para resolver problemas similares en el futuro. Este documento se va a dividir en 2 fases, la primera es la de contexto de la configuración inicial base que tenía el proyecto, y la segunda es la de la configuración de monitoreo con datadog.

## Tabla de Contenidos

### Fase 1: Contexto de la Configuración Inicial Base

- [Contexto de la Configuración Inicial Base](#contexto-de-la-configuración-inicial-base)
- [Diagnóstico de Errores](#diagnóstico-de-errores)
  - [Errores de Recursos Duplicados](#errores-de-recursos-duplicados)
  - [Manejo de Recursos en Diferentes Cuentas](#manejo-de-recursos-en-diferentes-cuentas)
- [Solución de Problemas](#solución-de-problemas)
  - [Modificación de Nombres de Recursos](#modificación-de-nombres-de-recursos)
  - [Ejecución de Scripts](#ejecución-de-scripts)
- [Seguridad y Buenas Prácticas](#seguridad-y-buenas-prácticas)
  - [Identificación de Información Sensible](#identificación-de-información-sensible)
  - [Manejo Seguro de Secretos](#manejo-seguro-de-secretos)
- [Documentación](#documentación)
- [Comandos Clave de Terraform](#comandos-clave-de-terraform)
- [Lecciones Aprendidas](#lecciones-aprendidas)

### Fase 2: Configuración de Monitoreo con Datadog

- [Integración de Datadog con AWS](#integración-de-datadog-con-aws)
- [Configuración de Dashboards](#configuración-de-dashboards)
- [Configuración de Alertas](#configuración-de-alertas)
- [Pruebas de Monitoreo](#pruebas-de-monitoreo)
- [Optimización de Costos](#optimización-de-costos)
- [Troubleshooting](#troubleshooting)
- [Conclusiones y Próximos Pasos](#conclusiones-y-próximos-pasos)

## Fase 1: Contexto de la Configuración Inicial Base

### Contexto de la Configuración Inicial Base

```
Explícame la configuración actual de @tf, y cual es el proposito o el resultado que se busca con esta configuración
```

Este prompt me ayudó a entender la configuración actual de @tf, y cual es el proposito o el resultado que se busca con esta configuración.

### Diagnóstico de Errores

### Errores de Recursos Duplicados

```
now i am facing this errros after apply
```

Este prompt se utilizó cuando aparecieron errores de recursos duplicados durante la ejecución de `terraform apply`. Los errores incluían:

- Política IAM "DatadogPolicy" ya existente
- Grupos de seguridad duplicados
- Problemas con ACL del bucket S3

### Manejo de Recursos en Diferentes Cuentas

```
antes de ejecutar este import, es importante saber que es posible que otro usuario haya creado estas configuraciones para su propia cuenta de aws, yo estoy creando la mia propia para mi usuario, el cual está desconectado de la otra cuenta de aws. debería comenzar con un estado vacio o que me recomiendas?
```

Este prompt fue crucial para entender que estábamos trabajando con una cuenta AWS independiente y que necesitábamos modificar los nombres de los recursos en lugar de importarlos.

## Solución de Problemas

### Modificación de Nombres de Recursos

Después de identificar los conflictos de nombres, se utilizaron prompts para modificar los recursos:

```
ahora despues de hacer los ajuestes en los nombre cuales son los pasos a seguir?
```

Este prompt nos llevó a ejecutar `terraform plan` para verificar los cambios y prepararnos para aplicarlos.

### Ejecución de Scripts

```
yo veo que en el archivo @s3.tf se ejecuta el generar-zip.sh, es necesario ejecutarlo manualmente? o solo con el apply funcionaría?. @tf aquí está toda la configuración de terraform
```

Este prompt ayudó a aclarar que el script `generar-zip.sh` se ejecuta automáticamente a través del recurso `null_resource` en Terraform.

## Seguridad y Buenas Prácticas

### Identificación de Información Sensible

```
de los archivos modificados en @tf que información sencible debería omitir en un commit?
```

Este prompt nos permitió identificar información sensible en la configuración:

- Claves API de Datadog en scripts de user_data
- Archivos de estado de Terraform
- Variables con información sensible

### Manejo Seguro de Secretos

```
en los scripts sh de backend y frontend me gustaría que obtuvieran esos datos de forma segura, en posible importarlos del archivo .env?
```

Este prompt llevó a la implementación de una solución para cargar variables sensibles desde un archivo `.env` en lugar de hardcodearlas en los scripts.

```
voy a obtar por no incluir esos scripts en el commit
```

Este prompt resultó en la actualización del archivo `.gitignore` para excluir los scripts con información sensible del control de versiones.

## Documentación

```
en este archivo @README.md documenta los pasos realizados para entender la configuración de terraform que está actualmente en el proyecto, y todos los retos que se tuvieron para poder configurar todo para mi usuario de aws, como el cambio de nombres etc, documenta este script también
```

Este prompt llevó a la creación de documentación detallada sobre la configuración de Terraform, los retos enfrentados y las soluciones implementadas.

## Comandos Clave de Terraform

Durante la conversación, se utilizaron varios comandos clave de Terraform:

```bash
# Inicializar Terraform
terraform init

# Ver el estado actual
terraform state list

# Eliminar recursos obsoletos del estado
terraform state rm aws_s3_bucket_object.backend_zip aws_s3_bucket_object.frontend_zip

# Planificar cambios
terraform plan

# Aplicar cambios
terraform apply
```

## Lecciones Aprendidas

1. **Nombres únicos**: Utilizar sufijos o prefijos únicos para evitar conflictos de nombres en recursos AWS.
2. **Actualizaciones de API**: Estar atento a cambios en las APIs de AWS (como el cambio de `aws_s3_bucket_object` a `aws_s3_object`).
3. **Manejo de secretos**: No hardcodear secretos en scripts o configuraciones.
4. **Control de versiones**: Excluir archivos sensibles del control de versiones.
5. **Documentación**: Documentar los retos y soluciones para referencia futura.

## Fase 2: Configuración de Monitoreo con Datadog

### Integración de Datadog con AWS

```
@tf Eres un Site Reliability Engineer en infraestructura, tu especialidad es el area de monitorizacion y observabilidad. Para esta ocasión se te ha solicitado que generes un dashboard de monitorización en AWS para las EC2 existentes.

Objetivos de la configuración:
- Configurar la integración de Datadog con AWS usando Terraform.
- Instalar el agente Datadog en la instancia EC2.
- Crear un dashboard en Datadog para visualizar métricas clave de AWS.

Utiliza la estructura que ya está configurada de terraform, como base, y extiende la configuración con los nuevos requerimientos solicitados
explícame que estas haciendo en cada paso de la configuración
```

```
i have these errors with the new configuration, some duplicate variable declarations. fix the errors
```
