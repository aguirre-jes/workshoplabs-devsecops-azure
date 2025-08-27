
# Demo 2: Eliminando Secretos del Código con Azure Key Vault en Azure DevOps Pipelines

## Requisitos previos

- Suscripción de Azure activa (puedes usar créditos FREE)
- Azure CLI instalada y autenticada (`az login`)
- Acceso a un proyecto de Azure DevOps (puedes crearlo con Azure CLI)

## Creación de recursos con Azure CLI

### 1. Crear un grupo de recursos (opcional)
```sh
az group create --name rg-demo-keyvault --location eastus
```

### 2. Crear un Azure Key Vault
```sh
az keyvault create --name demoKeyVault$RANDOM --resource-group rg-demo-keyvault --location eastus
```

### 3. Crear un proyecto de Azure DevOps (si no tienes uno)
```sh
az devops project create --name demo-keyvault-pipeline
```

### 4. Asignar permisos al pipeline para acceder al Key Vault
Debes identificar el Service Principal (o Managed Identity) que usará el pipeline y darle permisos de `get` y `list` en los secretos del Key Vault:

```sh
# Ejemplo: asignar permisos a un Service Principal
az keyvault set-policy --name <nombre-keyvault> --spn <appId-service-principal> --secret-permissions get list
```

Puedes obtener el appId del Service Principal desde Azure DevOps o crearlo con:
```sh
az ad sp create-for-rbac --name demo-keyvault-sp
```

> Consulta la documentación de Azure DevOps para obtener el objeto de identidad correcto según tu configuración de pipeline.

En esta demo aprenderás a proteger tus secretos y credenciales utilizando Azure Key Vault integrado en Azure DevOps Pipelines.

## Objetivo
Evitar almacenar secretos en el código fuente o variables de entorno del pipeline.

## Paso a paso
1. **Crear un Azure Key Vault**
2. **Agregar secretos (ejemplo: contraseñas, tokens)**
3. **Configurar Azure DevOps Pipeline para acceder a Key Vault**
4. **Consumir los secretos en el pipeline de manera segura**

## Buenas prácticas
- Nunca subas secretos al repositorio.
- Usa referencias a Key Vault en tus pipelines.
- Utiliza los créditos FREE de Azure para crear Key Vault.

## Recursos útiles
- [Documentación de Key Vault](https://learn.microsoft.com/es-es/azure/key-vault/)
- [Integración Key Vault y Azure DevOps](https://learn.microsoft.com/es-es/azure/devops/pipelines/library/key-vault)
