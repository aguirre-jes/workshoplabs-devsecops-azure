# Demo 1: De Vulnerable a Seguro con ACR

En esta demo aprenderás a utilizar Azure Container Registry (ACR) para escanear imágenes de contenedores y detectar vulnerabilidades.

## Objetivo

Identificar y remediar vulnerabilidades en imágenes OCI usando el scanner integrado de ACR.

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
terraform apply
```

8. Cuando termines, destruye los recursos para evitar cargos:

```sh
terraform plan -destroy -out main.destroy.tfplan
terraform apply main.destroy.tfplan
```

Los archivos relevantes son:

- `01-provider.tf`
- `02-resource-group.tf`
- `03-acr.tf`
- `04-defender-for-containers.tf`
- `versions.tf`
- `variables.tf`

## Recursos útiles

- [Documentación oficial de ACR](https://learn.microsoft.com/es-es/azure/container-registry/)
- [Precios de Defender for Containers](https://azure.microsoft.com/pricing/details/defender-for-cloud/)
