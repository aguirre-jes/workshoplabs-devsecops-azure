# Demo 3: Bloqueando Deployments Inseguros en AKS

En esta demo aprenderás a aplicar políticas de seguridad en Azure Kubernetes Service (AKS) para bloquear despliegues inseguros o con malas prácticas.

## Objetivo
Prevenir el despliegue de recursos inseguros en AKS usando políticas.

## Paso a paso
1. **Crear un cluster AKS demo (puedes usar el código Terraform proporcionado en módulos anteriores)**
2. **Configurar políticas de seguridad (ejemplo: Azure Policy para AKS)**
3. **Intentar desplegar recursos inseguros (ejemplo: contenedores como root, sin límites de recursos, etc.)**
4. **Observar el rechazo de los deployments inseguros**
5. **Corregir los manifiestos y desplegar de nuevo**

## Detalles importantes
- Explica cómo funcionan las políticas y cómo se aplican en AKS.
- Incluye ejemplos de manifiestos inseguros y seguros.
- Utiliza los créditos FREE de Azure para el cluster demo.

## Recursos útiles
- [Azure Policy para AKS](https://learn.microsoft.com/es-es/azure/aks/policy-concept)
- [Terraform AKS](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster)
