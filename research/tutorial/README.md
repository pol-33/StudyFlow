Este documento está estructurado para seguir el flujo de las diapositivas paso a paso. Recomendamos leerlo con las transparencias abiertas para una mejor comprensión e imagenes del proceso.

---

# AWS Fargate - Tutorial y Guía Práctica

**Asignatura:** CCBDA Q1 - MEI UPC  
**Autores:** Pol Plana, Zixin Zhang, Zhehan Xiang, Zhipeng Lin

---

## Tabla de Contenidos

1.  [Introducción y Relevancia](#1-introducción-y-relevancia)
2.  [Arquitectura y Comparativa](#2-arquitectura-y-comparativa)
3.  [Hands-on Teórico: Tutorial](#3-hands-on-teórico-tutorial)
4.  [Perspectiva de Costes y Recursos](#4-perspectiva-de-costes-y-recursos)

---

## 1. Introducción y Relevancia

### ¿Qué es AWS Fargate?
AWS Fargate se define como **"Serverless para contenedores"**. Es un motor de computación que permite ejecutar contenedores sin tener que gestionar servidores o clústeres.
*   Es similar a usar AWS Lambda, pero diseñado para contenedores Docker que tienen tiempos de ejecución más largos.
*   **Concepto clave:** Funciona integrándose nativamente con **Amazon ECS** (Elastic Container Service) y **Amazon EKS** (Kubernetes).

### El problema que resuelve
El método tradicional de usar contenedores en AWS implicaba gestionar instancias EC2. Esto conllevaba:
*   Gestionar parches y actualizaciones del Sistema Operativo.
*   Pagar por capacidad reservada aunque no se usara.

**Qué nos promete Fargate:** "Céntrate en tu aplicación, no en la infraestructura".

---

## 2. Arquitectura y Comparativa

Para entender Fargate, es necesario compararlo con el modelo tradicional de EC2.

### EC2 vs. Fargate

| Característica | Modelo EC2 | Modelo Fargate |
| :--- | :--- | :--- |
| **Control** | Eres dueño de la VM (Máquina Virtual). Tienes control total pero responsabilidad total. | No ves la VM. Mayor aislamiento de seguridad por defecto. |
| **Gestión** | Debes gestionar el SO, actualizaciones y agentes. | AWS gestiona la infraestructura subyacente (Serverless). |
| **Coste** | Pagas por capacidad reservada (instancia encendida) aunque no la uses. | Pagas por vCPU y RAM consumida al segundo. |


### ¿Cuándo usar cuál?

*   **Usar Fargate para:**
    *   Cargas de trabajo variables.
    *   Entornos de desarrollo.
    *   Cuando se quiere evitar la administración del Sistema Operativo.
*   **Usar EC2 para:**
    *   Cargas muy constantes y predecibles (optimización de costes).
    *   Control profundo del hardware (ej. necesidad de GPUs específicas).
    *   Uso de Reserved Instances para descuentos extras.


---

## 3. Hands-on Teórico: Tutorial

En esta sección os enseñamos a desplegar una aplicación web sencilla utilizando Docker y AWS Fargate.

### Conceptos Clave de ECS
Antes de empezar, definamos la jerarquía de ECS:
1.  **Task:** El bloque más pequeño. Es una instancia de un contenedor en ejecución.
2.  **Task Definition:** La "plantilla" o receta de la tarea (imagen Docker, CPU, Memoria).
3.  **Cluster:** Un grupo lógico de servicios y tareas.
4.  **Service:** El gestor que asegura que un número X de tareas estén siempre activas.


### Paso 1: Preparar y Dockerizar el proyecto
Partimos de una aplicación Python (Flask) muy sencilla.

**app.py:**
```python
from flask import render_template
from flask import Flask

app = Flask(__name__)

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/app')
def blog():
    return "Hello, from App!"

if __name__ == '__main__':
    app.run(threaded=True, host='0.0.0.0', port=8081)
```

**Dockerfile:**
```dockerfile
FROM python:3.7-slim

COPY ./requirements.txt /app/requirements.txt
WORKDIR /app
RUN pip install -r requirements.txt
COPY . /app
EXPOSE 8081
ENTRYPOINT [ "python" ]
CMD [ "app.py" ]
```


### Paso 2: Subir la imagen a ECR
Asumimos que la imagen ya ha sido construida y subida a **Amazon ECR (Elastic Container Registry)**.
*   Copia la **Image URI** (ej: `...amazonaws.com/flask-app:latest`), la necesitaremos más adelante.


### Paso 3: Crear el Cluster
1.  Vamos al servicio **Amazon ECS**.
2.  Hacemos clic en **Create Cluster**.
3.  Seleccionamos la plantilla **"Networking only"** (Powered by AWS Fargate).
4.  Asignamos un nombre, por ejemplo: `DemoAppCluster`.
5.  Creamos el cluster.


### Paso 4: Definir la Tarea (Task Definition)
Ahora definimos *cómo* debe ejecutarse nuestra app.
1.  En ECS, menú lateral: **Task Definitions** -> **Create new Task Definition**.
2.  Launch Type: **FARGATE**.
3.  Configuramos el tamaño de la tarea (Task Memory: 2GB, Task CPU: 1 vCPU).
4.  Hacemos clic en **Add container**:
    *   **Container name:** `DemoAppContainer`
    *   **Image:** Pegamos la URI de ECR que copiamos en el paso 2.
    *   **Memory Limits:** `2048` MiB.
    *   **Port mappings:** `8081` (el puerto expuesto en el Dockerfile).
5.  Finalizamos la creación de la Task Definition.


### Paso 5: Crear el Balanceador de Carga (ALB)
Para que los usuarios accedan a la app, necesitamos un Load Balancer. Esto se hace desde la consola de **EC2**.

1.  Ve a **EC2** -> **Load Balancers** -> **Create Load Balancer**.
2.  Tipo: **Application Load Balancer (ALB)**.
3.  **Basic Configuration:**
    *   Name: `DemoAppLB`.
    *   Scheme: Internet-facing.
    *   Listeners: HTTP puerto 80. (Si necesitas HTTPS, puedes configurarlo aquí, pero para este tutorial no cubriremos esa parte).
4.  **Availability Zones:** Selecciona tu VPC y marca todas las subredes deseadas.
5.  **Security Groups:** Crea uno nuevo que permita tráfico **TCP** en el puerto **80** desde cualquier origen (`0.0.0.0/0`). Dale el nombre y descripción `DemoAppLB-SecurityGroup`.
6.  **Routing (Target Group):**
    *   Target type: IP.
    *   Port: 8081 (el puerto de nuestro contenedor).
7.  Revisa y crea el Load Balancer.


### Paso 6: Crear el Servicio en ECS
Volvemos a nuestro cluster en **ECS** (`DemoAppCluster`) para lanzar la aplicación.

1.  Dentro del cluster, pestaña **Services** -> **Create**.
2.  **Launch type:** `FARGATE`.
3.  **Task Definition:** Selecciona la creada en el Paso 4 (`DemoTaskDefinition`).
4.  **Cluster:** `DemoAppCluster`.
5.  **Service name:** `DemoAppService`.
6.  **Number of tasks:** `2` (Esto asegura que siempre haya 2 réplicas funcionando. Si se quiere definir un máximo se puede hacer en la configuración opcional de Auto Scaling).


### Paso 7: Configuración de Red y Balanceo en el Servicio
En el asistente de creación del Servicio (paso 2):

1.  **VPC / Subnets:** Selecciona la VPC y las subredes donde quieres desplegar.
2.  **Load Balancing:**
    *   Selecciona **Application Load Balancer**.
    *   Elige el balanceador creado anteriormente (`DemoAppLB`).
    *   Haz clic en **Add to load balancer** junto al nombre de tu contenedor.
    *   Asegúrate de que el "Target group name" sea `DemoAppTargetGroup` (el creado en el Paso 5).

*(Opcional: Como paso 3 puedes configurar Auto Scaling, para que el número de tareas suba o baje según la demanda de CPU/RAM, pero para este tutorial lo dejaremos fijo).*


### Paso 8: Despliegue y Corrección de Security Groups
Al finalizar el asistente, el servicio comenzará a crear las tareas.
*   **Estado inicial:** Verás las tareas en estado `PENDING` y luego `RUNNING`.
*   **Problema:** Las tareas fallarán y se reiniciarán infinitamente, debido a los health checks del balanceador. Esto ocurre porque el **Security Group de la Tarea** no permite tráfico entrante desde el **Security Group del Balanceador**.

**Solución:**
1.  Haz clic en la Tarea o Servicio para ver los detalles y busca el **Security Group** asignado (ej: `sg-0827...`).
2.  Haz clic en él para editarlo (te llevará a la consola de VPC).
3.  Pestaña **Inbound rules** -> **Edit inbound rules**.
4.  Añade una regla:
    *   Type: **All TCP**.
    *   Source: Custom + Seleccionar el ID del Security Group de tu Load Balancer.
5.  Guarda los cambios.


### Paso 9: Verificación Final
1.  Vuelve a la consola de **EC2** -> **Load Balancers**.
2.  Selecciona tu `DemoAppLB`.
3.  Copia el **DNS name** (ej: `DemoAppLB-186...us-east-1.elb.amazonaws.com`).
4.  Pégalo en tu navegador.
5.  Deberías ver: **"Hello, from App!"**.


---

## 4. Perspectiva de Costes y Recursos

### Modelo de Precios
En Fargate el modelo es sencillo pero hay que vigilarlo:
*   **Pagas por:** vCPU y GB de memoria consumidos **por segundo**.
*   **Advertencia:** Cuidado con dejar tareas "zombies" encendidas. Aunque no reciban tráfico, si la tarea está "Running", AWS está cobrando.
*   **Right-Sizing:** Es vital ajustar la definición de la tarea (CPU/RAM) a lo que realmente necesita la app para no desperdiciar dinero.


### Comparativa de TCO (Total Cost of Ownership)
Aunque Fargate puede parecer más caro por unidad de computación pura que una instancia EC2 reservada, el TCO puede ser menor para muchas empresas al eliminar los costes operativos de administración (horas de ingeniería gestionando parches, escalado, seguridad del SO).

### Recursos de Aprendizaje Recomendados
*   [Página oficial de AWS Fargate](https://aws.amazon.com/es/fargate/)
*   [AWS Fargate Workshop](https://awsworkshop.io/tags/fargate/)
*   [Blog: What is AWS Fargate? (Spacelift)](https://spacelift.io/blog/what-is-aws-fargate)
*   [Video: AWS Fargate - Getting Started](https://www.youtube.com/watch?v=DVrGXjjkpig)
*   [Video: AWS Fargate - Deep Dive](https://www.youtube.com/watch?v=o7s-eigrMAI)


Esperamos que este tutorial os ayude a entender y desplegar vuestras primeras aplicaciones en AWS Fargate.