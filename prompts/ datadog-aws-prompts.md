# Monitoreo y Seguridad en Infraestructura AWS

## Asistente utilizado
Cursor GPT-4o

## Prompts y respuestas

### Prompt 1:
**Usuario**: Toma el rol de un DevSecOps especializado en Infraestructura y Observabilidad, necesito que estudies el @Codebase del proyecto, poniendo especial enfasis en el codigo de Terraform alojado en @tf , dime lo que has entendido de forma resumida

**Respuesta**: di una respuesta resumida y clara sobre el codigo de terraform

### Prompt 2:
**Usuario**: hay que extender el codigo actual de terraform para:

    - Configurar la integración de Datadog con AWS usando Terraform.
    - Instalar el agente Datadog en la instancia EC2.
    - Crear un dashboard en Datadog para visualizar métricas clave de AWS.

dime como puedo hacerlo y que pasos he de seguir, no implementes codigo por el momento

**Respuesta**: mostre los pasos que he de seguir para implementar la integración de Datadog con AWS usando Terraform, y que pasos he de seguir, desde la configuracion de los permisos de acceso a AWS, hasta la creacion del dashboard en Datadog

### Prompt 3:
**Usuario**: como instalo el AWS CLI?

**Respuesta**: mostre los pasos que he de seguir para instalar el AWS CLI, y que pasos he de seguir, desde la instalacion de la herramienta, hasta la configuracion de los permisos de acceso a AWS

### Prompt 4:
**Usuario**: Ahora necesito que me definas un dashboard en Datadog que muestre métricas relevantes de mi infraestructura AWS. Utiliza el script @dashboard.tf 

**Respuesta**: Defini un dashboard en Datadog que muestre métricas relevantes de uilizacion de CPU, red y disco de las instancias EC2

### Prompt 5:
**Usuario**: Vamos a hacer check de los pasos que hemos hecho, comprueba para cada caso si esta correcta acorde a la configuracion de Terraform:

a) Configurar la Integración AWS-Datadog:

    Utiliza Terraform para configurar la integración entre AWS y Datadog, siguiendo la guía proporcionada.

b) Configurar el Proveedor Datadog:

    Añade el proveedor Datadog a tu configuración de Terraform.

c) Instalar el Agente Datadog:

    Modifica el script de usuario de la instancia EC2 para instalar y configurar el agente Datadog.

d) Crear un Dashboard:

    Utiliza Terraform para definir un dashboard en Datadog que muestre métricas relevantes de tu infraestructura AWS.

dime si ves algo que eches en falta o no

**Respuesta**: Estuve revisando el codigo de terraform y no veo nada que eches en falta, todo parece estar bien configurado
