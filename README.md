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
travis encrypt-file service-account.json -r facundoalarcon/multi-containers-k8s --com
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
## Travis File

```
# usa sudo
sudo: required
services:
# usa docker
  - docker
# variables de entorno
env:
  gobal:
    # recupera el ultimo sha de git para usarlo luego en el script deploy.sh
    - SHA=$(git rev-parse HEAD)
    # una variable que se usa en el sdk de google indicandole que no muestre ninguna advertencia cuando se ejecute el comando gcloud que pide algun yes/no, esto porque no tenemos la posibilidad de usarlo en un travis environment
    - CLOUDSDK_CORE_DISABLE_PROMPTS=1
before_install:
  # sale de travis
  - openssl aes-256-cbc -K $encrypted_9f3b5599b056_key -iv $encrypted_9f3b5599b056_iv -in service-account.json.enc -out service-account.json -d
  # las dos siguientes lineas son para google cloud sdk
  # descarga el sdk de google cloud y lo instala localmente en la instancia de travis-ci
  - curl https://sdk.cloud.google.com | bash > /dev/null;
  # se usa una config de path.bash.inc del directorio principal de google cloud que va a modifrcar algunas cosas en nuestro server asignado por travis-ci
  - source $HOME/google-cloud-sdk/path.bash.inc
  # hace un update al kubectl por medio del cli de google
  - gcloud components update kubectl
  # usa las credenciales del json para autenticarse en la cuenta de google con un service account (tipo IAM user de aws)
  # con el comando de abajo desencripta el json encriptado
  - gcloud auth activate-service-account --key-file service-account.json
  # seleccionar el proyecto con el id del mismo
  - gcloud config set project multi-k8s-297120
  # indicar la AZ
  - gcloud config set compute/zone us-central1-a
  # indicar el nombre del cluster k8s
  - gcloud container clusters get-credentials multi-cluster
  # autenticacion en Docker por medio del servio previamente indicado de docker
  # recordar que esas son variables de entorno en travis
  - echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
  # test client, crea la imagen de test
  - docker build -t facundoalarcon/react-test -f ./client/Dockerfile.dev ./client

script:
  # run and test la imagen previamente creada, hace un test de cobertura con node (npm)
  # (esto es para que travis ejecute las pruebas, en este caso realmente no estamos haciendo algun test profundo)
  # esto deberia reemplazarse con los comandos que se requieran para hacer un test real
  - docker run -e CI=true facundoalarcon/react-test npm test

deploy:
  # no hay ningun script preestablecido como en el caso de beanstalk, en este caso vamos a crearlo de 0
  # por tanto le decimos a travis que ejecute solo un script
  provider: script
  # le decimos que vamos a armar un script llamado deploy
  # esto va a estar en el root folder directory
  script: bash ./deploy.sh
  # lo vamos a ejecutar en la rama master
  on:
    branch: master
```