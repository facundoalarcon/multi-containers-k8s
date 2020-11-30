## Docker commands for ruby
Crear un container con rubi para usar Travis
En este caso se monta el directorio del proyecto y todos los cambios en los archivos se ven reflejados automaticamente en el container
```
docker run -it -v $(pwd):/app ruby:2.4 sh
```
### Travis
#### github tokens
https://github.com/settings/tokens
```
gem install travis
travis login --com --github-token <token>
travis encrypt-file service-account.json -r facundoalarcon/multi-k8s --com
```
```
script:
  - docker run -e CI=true USERNAME/react-test npm test
```
con esto creamos un archivo json encriptado basado en el json original (que tiene datos del service-account de google)
el archivo original descargado de google se borra y se deja solo el encriptado
Esto me va a dejar dos variables de entorno en travis

### Configuring the Gcloud CLI on Google Cloud
conectarse al cluster k8s
```
gcloud config set project <project-id>
gcloud config set compute/zone <AZ>
gcloud container clusters get-credentials <name k8s cluster>
```
#### create secret password for PostGresql from GCP shell
tiene que se como esta configurado en los archivos de k8s
```
kubectl create secret generic SECRET_NAME --from-literal KEY=VALUE
kubectl create secret generic pgpassword --from-literal PGPASSWORD=myPassword12345
```

## Using Helm
Helm v3. This is a major update, as it removes the use of Tiller

[repo](https://github.com/kubernetes/ingress-nginx)

[page](https://kubernetes.github.io/ingress-nginx/deploy/)

[Helm](https://kubernetes.github.io/ingress-nginx/deploy/#using-helm) es escencialmente un programa que nos permite administrar SW dentro de un cluster k8s [repo](https://github.com/helm/helm)

[Quick start Guide](https://helm.sh/docs/intro/quickstart/)

in GCP use [FROM SCRIPT](https://helm.sh/docs/intro/install/)

### Tiller
Tiller viene junto con Helm, es un server que corre dentro de nuestro cluster k8s, sera el responsable de configurar algunas cosas en el cluster e instalar otras

A[Helm (Client)] --> B[Tiller (Server)]

### RBAC (Role Based Access Control)
- limita quien puede acceder a el cluster k8s
- Enabed on GCP by default

*User accounts* *Services accounts* for authentication
#### User accounts
Identifies a *person* administering our cluster

#### Services accounts
Identifies a *pod* administering a cluster

*ClusterRoleBinding* *RoleBinding* for authozation
#### ClusterRoleBinding
Authorized an account to do a certain set of actions across the entire cluster

#### RoleBinding
Authorizes an account to do a certain set of actions in a *single namespace*

### Finish Helm installation
[Helm](https://kubernetes.github.io/ingress-nginx/deploy/#using-helm)
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install my-release ingress-nginx/ingress-nginx
```