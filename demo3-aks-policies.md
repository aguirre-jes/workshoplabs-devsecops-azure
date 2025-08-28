

# Demo 3: Bloqueando Deployments Inseguros en AKS con Gatekeeper (OPA)

En esta demo aprenderás a proteger tu clúster AKS bloqueando despliegues inseguros mediante el uso de Gatekeeper, un controlador de admisión externo basado en OPA (Open Policy Agent). Gatekeeper permite definir y aplicar políticas personalizadas de seguridad en Kubernetes, independientes de Azure Policy.

## Objetivo
Prevenir el despliegue de recursos inseguros en AKS usando Gatekeeper OPA como controlador de admisión.

## Buenas prácticas
- Usa controladores de admisión como Gatekeeper para reforzar la seguridad de tus clusters.
- Nunca ignores los mensajes de error de políticas: corrige los manifiestos.
- Utiliza los créditos FREE de Azure para el cluster demo.

## Requisitos previos
- Azure CLI instalada y autenticada (`az login`)
- Terraform instalado
- kubectl instalado
- Suscripción de Azure activa
- Acceso al repo de Terraform para crear el cluster AKS

## Nota importante sobre Azure Policy
Si tu clúster AKS tiene habilitado el add-on de Azure Policy, **no podrás crear ni modificar ConstraintTemplates ni Constraints personalizados de Gatekeeper**. Para usar Gatekeeper de forma independiente, primero deshabilita el add-on de Azure Policy desde el portal de Azure:

1. Ve a tu clúster AKS en el portal de Azure.
2. En el menú izquierdo, selecciona **Policies** o **Políticas**.
3. Haz clic en **Deshabilitar** (Disable) para el add-on de Azure Policy.
4. Espera a que la operación finalice antes de continuar.

Más información: [Azure Policy Add-on for AKS](https://learn.microsoft.com/en-us/azure/aks/policy-concept)

---

## Paso a paso
1. **Crear un cluster AKS demo usando Terraform**
2. **Instalar Gatekeeper en el clúster**
3. **Aplicar políticas personalizadas con Gatekeeper (OPA)**
4. **Intentar desplegar recursos inseguros**
5. **Observar el rechazo de los deployments inseguros**
6. **Corregir los manifiestos y desplegar de nuevo**

---

## 1. Crear un cluster AKS demo con Terraform

Puedes usar el siguiente repositorio para crear el cluster:

> [Repo Terraform AKS - workshoplabs-terraform-azure12](https://github.com/aguirre-jes/workshoplabs-terraform-azure12/tree/main/crear-cluster-aks)

Pasos básicos:
```sh
git clone https://github.com/aguirre-jes/workshoplabs-terraform-azure12.git
cd workshoplabs-terraform-azure12/crear-cluster-aks
# Edita variables si es necesario (por ejemplo, en terraform.tfvars)
terraform init
terraform apply
```

Validar el cluster:
```sh
az aks get-credentials --resource-group <rg> --name <aks-name>
kubectl get nodes
```

---

## 2. Instalar Gatekeeper en el clúster AKS

Gatekeeper es un controlador de admisión que permite definir políticas OPA (Open Policy Agent) para Kubernetes. Más información: [Gatekeeper Docs](https://open-policy-agent.github.io/gatekeeper/website/docs/)

Instala Gatekeeper ejecutando:
```sh
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.14/deploy/gatekeeper.yaml
```

Verifica que los pods estén en estado Running:
```sh
kubectl get pods -n gatekeeper-system
```

---

## 3. Aplicar políticas personalizadas con Gatekeeper (OPA)

Para bloquear pods inseguros (por ejemplo, que corran como root), crea un ConstraintTemplate y una Constraint:

**constrainttemplate-deny-root.yaml**
```yaml
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
	name: k8sdenyrootuser
spec:
	crd:
		spec:
			names:
				kind: K8sDenyRootUser
	targets:
		- target: admission.k8s.gatekeeper.sh
			rego: |
				package k8sdenyrootuser
				violation[{"msg": msg}] {
					input.review.object.spec.containers[_].securityContext.runAsUser == 0
					msg := "No se permite crear pods con runAsUser: 0 (root)"
				}
```

**constraint-deny-root.yaml**
```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sDenyRootUser
metadata:
	name: deny-root-user
spec:
	match:
		kinds:
			- apiGroups: [""]
				kinds: ["Pod"]
```

Aplica ambos archivos:
```sh
kubectl apply -f constrainttemplate-deny-root.yaml
kubectl apply -f constraint-deny-root.yaml
```

Valida que los recursos se crearon correctamente:
```sh
kubectl get constrainttemplates
kubectl get constraints
kubectl describe constrainttemplate k8sdenyrootuser
kubectl describe k8sdenyrootuser deny-root-user
```
---

## 4. Ejemplo de manifiestos inseguros y seguros

### Manifiesto inseguro (será bloqueado por Gatekeeper)
```yaml
apiVersion: v1
kind: Pod
metadata:
	name: pod-inseguro
spec:
	containers:
		- name: nginx
			image: nginx
			securityContext:
				runAsUser: 0 # root
```

### Manifiesto seguro (cumple la política)
```yaml
apiVersion: v1
kind: Pod
metadata:
	name: pod-seguro
spec:
	containers:
		- name: nginx
			image: nginx
			securityContext:
				runAsUser: 1000
```

---


## 5. Probar y observar el rechazo de deployments inseguros

Aplica el manifiesto inseguro:
```sh
kubectl apply -f pod-inseguro.yaml
```
Deberías ver un error similar a:
```
Error from server (Forbidden): error when creating "pod-inseguro.yaml": admission webhook "validation.gatekeeper.sh" denied the request: [deny-root-user] No se permite crear pods con runAsUser: 0 (root)
```

Corrige el manifiesto y vuelve a aplicar:
```sh
kubectl apply -f pod-seguro.yaml
```
Ahora el pod debería crearse correctamente.

---

## 6. Troubleshooting y tips
- Si el manifiesto inseguro no es bloqueado, revisa que el add-on de Azure Policy esté deshabilitado y que Gatekeeper esté instalado correctamente.
- Puedes ver los logs de Gatekeeper en el cluster para más detalles:
	```sh
	kubectl get pods -n gatekeeper-system
	kubectl logs <pod-gatekeeper> -n gatekeeper-system
	```
- Consulta la documentación oficial de Gatekeeper para más ejemplos y políticas personalizadas: https://open-policy-agent.github.io/gatekeeper/website/docs/

---

## Recursos útiles
- [Gatekeeper (OPA) - Documentación oficial](https://open-policy-agent.github.io/gatekeeper/website/docs/)
- [Terraform AKS](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster)
- [Repo Terraform AKS - workshoplabs-terraform-azure12](https://github.com/aguirre-jes/workshoplabs-terraform-azure12/tree/main/crear-cluster-aks)
