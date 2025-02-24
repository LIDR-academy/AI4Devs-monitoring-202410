# Prompts para Integración AWS-Datadog

## Prompt 1: Configuración Inicial de Monitoreo

Necesito implementar monitoreo de AWS usando Datadog con Terraform. Los requerimientos son:

- Usar variables de entorno para las claves de Datadog (TF_VAR_datadog_api_key y TF_VAR_datadog_app_key)
- Crear los roles y políticas necesarias en AWS
- Monitorear métricas de CloudWatch
- El servidor Datadog está en la región us5
- Crear un dashboard para visualizar métricas de EC2

## Prompt 2: Solución al Error de Integración

Estoy teniendo un error 409 Conflict al intentar crear la integración AWS-Datadog. Necesito:

- Mantener el rol IAM que ya existe (DatadogAWSIntegrationRole)
- Usar el external_id actual: "6cc0198030fc4078ab176961142b6672"
- Separar la gestión de roles/políticas de la integración
- No interrumpir la recolección de métricas actual
- Evitar conflictos con la configuración existente

## Prompt 3: Creación de Dashboard

Necesito crear un dashboard en Datadog para ver las métricas de EC2:

- Usar gráficos de tipo timeseries_definition
- Mostrar CPU, memoria y red de las instancias
- Detectar automáticamente las instancias EC2
- Filtrar usando el tag env:prod
- Usar ":" en lugar de "=" en las queries
- Comentarios en español

## Prompt 4: Permisos AWS

Necesito configurar los permisos mínimos en AWS para que Datadog pueda:

- Leer métricas de CloudWatch
- Ver información de instancias EC2
- Acceder a logs de CloudWatch
- Leer tags de recursos
- Todo siguiendo el principio de mínimo privilegio

## Prompt 5: Limpieza de Configuración

La configuración actual tiene problemas. Necesito:

- Eliminar recursos duplicados del state
- Actualizar a las últimas versiones de providers
- Mantener solo lo necesario en AWS
- Resolver problemas de dependencias circulares
- Documentar todos los cambios
