
# Demo 2: Eliminando Secretos del Código con Azure Key Vault en Azure DevOps Pipelines

## Objetivo principal
Evitar almacenar secretos en el código fuente o variables de entorno del pipeline. En esta demo aprenderás a proteger tus secretos y credenciales utilizando Azure Key Vault integrado en Azure DevOps Pipelines.

## Buenas prácticas
- Nunca subas secretos al repositorio.
- Usa referencias a Key Vault en tus pipelines.
- Utiliza los créditos FREE de Azure para crear Key Vault.

## Requisitos previos

- Suscripción de Azure activa (puedes usar créditos FREE)
- Azure CLI instalada y autenticada (`az login`)
- Acceso a un proyecto de Azure DevOps (puedes crearlo con Azure CLI)

## Paso a paso
1. **Crear un Azure Key Vault**
2. **Agregar secretos (ejemplo: contraseñas, tokens)**
3. **Configurar Azure DevOps Pipeline para acceder a Key Vault**
4. **Consumir los secretos en el pipeline de manera segura**

---

## 1. Creación de recursos con Azure CLI

### a) Crear un grupo de recursos (opcional)
```sh
az group create --name rg-demo-keyvault --location eastus
```

#### Validar grupo de recursos
```sh
az group show --name rg-demo-keyvault
```

### b) Crear un Azure Key Vault
```sh
az keyvault create --name demoKeyVault$RANDOM --resource-group rg-demo-keyvault --location eastus
```

#### Validar Key Vault
```sh
az keyvault show --name <nombre-keyvault> --resource-group rg-demo-keyvault
```

### c) Crear secretos en Key Vault
Puedes crear secretos sensibles que suelen usarse en pipelines, por ejemplo:
```sh
# Token de API
az keyvault secret set --vault-name <nombre-keyvault> --name "ApiToken" --value "12345-abcde-67890"

# Clave de acceso a storage
az keyvault secret set --vault-name <nombre-keyvault> --name "StorageAccessKey" --value "STORAGE_KEY_EXAMPLE"

# Webhook secreto
az keyvault secret set --vault-name <nombre-keyvault> --name "WebhookSecret" --value "webhook-secret-value"
```

Puedes validar los secretos creados con:
```sh
az keyvault secret list --vault-name <nombre-keyvault>
```

### d) Crear un proyecto de Azure DevOps (si no tienes uno)
```sh
az devops project create --name demo-keyvault-pipeline
```

---

## 2. Crear e integrar un Service Principal para el pipeline

### a) ¿Qué es un Service Principal?
Un Service Principal es una identidad de aplicación en Azure que permite a scripts, pipelines o aplicaciones autenticarse y acceder a recursos de Azure con permisos específicos, sin usar credenciales personales.

### b) Crear un Service Principal con Azure CLI
```sh
az ad sp create-for-rbac --name demo-keyvault-sp
```
Esto generará:
- appId: identificador del Service Principal
- password: secreto para autenticación
- tenant: ID del tenant de Azure

Guarda estos valores, los necesitarás para la integración.

### c) Asignar permisos al Service Principal en el Key Vault
Si tu Key Vault fue creado con la opción `--enable-rbac-authorization` (RBAC activado, valor por defecto recomendado), debes asignar permisos usando Azure RBAC:
```sh
az role assignment create --assignee <appId-service-principal> \
	--role "Key Vault Secrets User" \
	--scope /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.KeyVault/vaults/<nombre-keyvault>
```

> Si tu Key Vault NO tiene RBAC activado, puedes usar el método clásico con set-policy:
> ```sh
> az keyvault set-policy --name <nombre-keyvault> --spn <appId-service-principal> --secret-permissions get list
> ```

---

## 3. Integración con Azure DevOps

### a) Crear la Service Connection en Azure DevOps
1. Ve a tu proyecto de Azure DevOps.
2. En el menú lateral, entra a **Project settings** → **Service connections** → **New service connection** → selecciona **Azure Resource Manager**.
3. Elige la opción **Service principal (manual)**.
4. Completa los campos así:
	 - **Scope Level**: selecciona **Subscription** y elige la suscripción donde está el Key Vault.
	 - **Authentication**: selecciona **Service principal key**.
	 - **Application (client) ID**: pega el `appId` generado por la CLI.
	 - **Client secret**: pega el `password` generado por la CLI.
	 - **Directory (tenant) ID**: pega el `tenant` generado por la CLI.
	 - **Service Connection Name**: ponle un nombre descriptivo, por ejemplo, `sp-keyvault-demo`.
	 - (Opcional) **Description**: agrega una descripción si lo deseas.
5. Haz clic en **Verify and save** para crear la conexión.
6. Usa esta conexión en tu pipeline para que Azure DevOps pueda acceder al Key Vault de forma segura.

> Todo este flujo puede hacerse sin usar el portal de Azure, salvo la creación de la Service Connection en Azure DevOps, que requiere la interfaz web.

### b) Crear el grupo de variables vinculado a Key Vault en Azure DevOps
1. Ve a tu proyecto en Azure DevOps.
2. En el menú lateral, selecciona **Pipelines** → **Library**.
3. Haz clic en **+ Variable group**.
4. Ponle nombre, por ejemplo, `keyvault-secrets`.
5. Marca la opción **Link secrets from an Azure Key Vault as variables**.
6. Selecciona la Service Connection creada y el Key Vault correspondiente.
7. Elige los secretos que quieres importar como variables.
8. Guarda el grupo.

> **Nota de troubleshooting:**
> Si al intentar vincular el Key Vault en Azure DevOps ves el mensaje "No key vaults found in the selected subscription", asegúrate de que el Service Principal usado en la Service Connection tenga el rol "Reader" sobre el grupo de recursos o la suscripción donde está el Key Vault:
> ```sh
> az role assignment create --assignee <appId-service-principal> --role "Reader" --scope /subscriptions/<subscription-id>/resourceGroups/<resource-group>
> ```
> Espera unos minutos tras asignar el rol y vuelve a intentar la vinculación.

Ahora tu pipeline podrá usar los secretos del Key Vault con:
```yaml
variables:
	- group: keyvault-secrets
```

---

## 4. Ejemplo de pipeline de Azure DevOps y advertencias de seguridad

```yaml
trigger:
	branches:
		include:
			- main


	vmImage: 'ubuntu-latest'

variables:
	- group: keyvault-secrets # Nombre del grupo de variables vinculado al Key Vault

steps:
	- script: |
			echo "ApiToken: $(ApiToken)"
			echo "StorageAccessKey: $(StorageAccessKey)"
			echo "WebhookSecret: $(WebhookSecret)"
		displayName: 'Mostrar valores obtenidos del Key Vault'
```

> ⚠️ **Advertencia:**
> Cuando los secretos provienen de Azure Key Vault, Azure DevOps siempre oculta su valor real en la salida del pipeline y los muestra como `***`, incluso si intentas imprimirlos. Esto es por seguridad y no se puede modificar. Si necesitas validar el valor real, hazlo directamente en Azure Key Vault o usando la CLI, nunca en la consola del pipeline.

> Nota: Para pruebas, los secretos se imprimen en consola. En producción, nunca imprimas valores sensibles.

---

## Recursos útiles
- [Documentación de Key Vault](https://learn.microsoft.com/es-es/azure/key-vault/)
- [Integración Key Vault y Azure DevOps](https://learn.microsoft.com/es-es/azure/devops/pipelines/library/key-vault)
