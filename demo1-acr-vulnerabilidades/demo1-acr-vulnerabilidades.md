
# Demo 1: De Vulnerable a Seguro con ACR

En esta demo aprenderás a utilizar Azure Container Registry (ACR) para escanear imágenes de contenedores y detectar vulnerabilidades.

## Objetivo

Identificar y remediar vulnerabilidades en imágenes OCI usando el scanner integrado de ACR.

## ¿Qué es Azure Defender for Cloud y cómo se conecta con ACR?

Azure Defender for Cloud es una solución de seguridad nativa de Azure que ayuda a proteger tus recursos en la nube, incluyendo máquinas virtuales, bases de datos, almacenamiento y servicios de contenedores. Cuando habilitas el plan "Microsoft Defender for Containers", Defender for Cloud se integra con Azure Container Registry (ACR) para escanear automáticamente las imágenes de contenedor en busca de vulnerabilidades conocidas (CVEs).

**¿Por qué es importante?**
- Permite identificar vulnerabilidades en las imágenes antes de que sean desplegadas en producción.
- Ayuda a cumplir con buenas prácticas de DevSecOps y requisitos de cumplimiento.

**¿Cómo se conecta con ACR?**
- Al habilitar Defender for Containers, cada vez que subes una imagen a tu ACR, se dispara un escaneo automático.
- Además, todas las imágenes existentes en el ACR se re-escanean automáticamente cada 24 horas para detectar nuevas vulnerabilidades.
- Los resultados del escaneo se pueden consultar desde el portal de Azure, en la sección de Seguridad del ACR.

## Paso a paso

1. **Crear un Azure Container Registry (ACR)**
2. **Subir una imagen vulnerable**
3. **Ejecutar el escaneo de vulnerabilidades**
4. **Revisar los resultados y recomendaciones**
5. **Actualizar la imagen y volver a escanear**

## Recomendaciones

- Utiliza los créditos FREE de Azure para crear el ACR.
- Elimina los recursos al finalizar para evitar cargos.

## Advertencia sobre costos y licenciamiento

El escaneo de vulnerabilidades en ACR está incluido en Microsoft Defender for Containers. Este servicio tiene un costo adicional que se cobra por vCore/mes aprovisionado en los recursos protegidos (incluye tanto ACR como AKS). El precio aproximado es de $6.87 USD por vCore/mes, pero puede variar según la región y el tipo de suscripción. El uso de Defender for Containers puede consumir parte de los créditos FREE de Azure, pero si los créditos se agotan, se empezará a cobrar a la suscripción.

Consulta siempre la [página oficial de precios de Defender for Containers](https://azure.microsoft.com/pricing/details/defender-for-cloud/) para información actualizada y revisa el uso de tus créditos en el portal de Azure.


## Despliegue de la infraestructura con Terraform

Puedes crear el Azure Container Registry y habilitar el escaneo de vulnerabilidades automáticamente usando los archivos `.tf` incluidos en este repositorio.

### Pasos

1. Instala [Terraform](https://www.terraform.io/downloads.html) si no lo tienes.
2. Autentícate en Azure: `az login`
3. Abre el archivo `variables.tf` y reemplaza el valor de `subscription_id` por el ID de tu suscripción de Azure:

```hcl
variable "subscription_id" {
	description = "ID de la suscripción de Azure donde se desplegarán los recursos."
	type        = string
	default     = "<REEMPLAZAR_CON_TU_SUBSCRIPTION_ID>"
}
```

4. Inicializa el entorno de Terraform:

```sh
terraform init
```

5. Validar:

```sh
terraform validate
```

6. Previsualiza los cambios:

```sh
terraform plan -out main.tfplan
```

7. Aplica la infraestructura:

```sh
terraform apply main.tfplan
```

### Validar la creación de recursos en Azure

Después de aplicar la infraestructura, puedes validar que todo se creó correctamente ejecutando los siguientes comandos:

```sh
# Verifica el grupo de recursos
az group show --name rg-demo-acr

# Verifica el Azure Container Registry
az acr show --name demodevsecopsacr --resource-group rg-demo-acr

# Verifica que Defender for Containers esté habilitado para Container Registry
az security pricing show --name ContainerRegistry
```

Las salidas deben mostrar el estado "Succeeded" y la información de los recursos creados.

### Probar el escaneo de vulnerabilidades en ACR

Para verificar que el escáner de vulnerabilidades está funcionando, sigue estos pasos:

1. Inicia sesión en tu ACR desde Docker:

	```sh
	az acr login --name demodevsecopsacr
	```

	> **Nota de troubleshooting:**
	> Si ves un error como:
	>
	> ```
	> Error saving credentials: error storing credentials - err: exit status 1, out: `Docker credential helper 'docker-credential-desktop' not found: write EPIPE.`
	> Login failed.
	> ```
	>
	> Es probable que tu archivo `~/.docker/config.json` tenga una línea como:
	>
	> ```json
	> { "credsStore": "desktop" }
	> ```
	>
	> O similar (por ejemplo, `credStore`). Para solucionarlo, elimina esa línea y deja el archivo así:
	>
	> ```json
	> {}
	> ```
	>
	> Puedes hacerlo con:
	>
	> ```sh
	> sed -i '/credStore/d' ~/.docker/config.json
	> ```
	>
	> Luego intenta de nuevo el login.

2. Etiqueta una imagen local (por ejemplo, hello-world) para tu ACR:

	```sh
	docker pull ubuntu:18.04
	docker tag ubuntu:18.04 demodevsecopsacr.azurecr.io/ubuntu:vuln
	```

3. Sube la imagen al ACR:

	```sh
	docker push demodevsecopsacr.azurecr.io/ubuntu:vuln
	```


4. Ve al portal de Azure → tu ACR → Seguridad (Microsoft Defender for Cloud) → Imágenes.

	Allí verás el resultado del escaneo de vulnerabilidades para la imagen subida. Defender for Containers escaneará automáticamente las imágenes nuevas.

> **Importante:**
> - Para que el escaneo funcione, debes tener activado el plan "Microsoft Defender for Containers" en Defender for Cloud para tu suscripción. Si está en "Off", actívalo desde el portal de Azure en Defender for Cloud → Administración del entorno → Planes de protección.
> - El escaneo de vulnerabilidades se ejecuta automáticamente al subir una nueva imagen. Para imágenes ya existentes, el escaneo se realiza cada 24 horas y no es posible forzar un escaneo inmediato.


## Destruccion de recursos creados

```sh
terraform plan -destroy -out main.destroy.tfplan
terraform apply main.destroy.tfplan
```

> **Importante:**
> - Es tu responsabilidad verificar en el portal de Azure o con Azure CLI que todos los recursos hayan sido eliminados correctamente después de ejecutar los comandos de destrucción. Esto evitará cargos innecesarios en tu suscripción.


## Archivos importantes

- `01-provider.tf`: Configura el proveedor de Azure (azurerm) y la suscripción donde se desplegarán los recursos.
- `02-resource-group.tf`: Define el grupo de recursos de Azure que agrupa todos los recursos de la demo.
- `03-acr.tf`: Declara y configura el Azure Container Registry (ACR) donde se almacenarán las imágenes de contenedor.
- `04-defender-for-containers.tf`: Habilita Microsoft Defender for Containers para el escaneo de vulnerabilidades en el ACR.
- `versions.tf`: Especifica las versiones requeridas de Terraform y del proveedor de Azure para asegurar compatibilidad.
- `variables.tf`: Declara las variables de entrada, como el subscription_id, para parametrizar el despliegue.

## Recursos útiles

- [Documentación oficial de ACR](https://learn.microsoft.com/es-es/azure/container-registry/)
- [Precios de Defender for Containers](https://azure.microsoft.com/pricing/details/defender-for-cloud/)
