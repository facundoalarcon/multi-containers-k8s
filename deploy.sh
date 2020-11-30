#!/bin/bash
# build and push images to our docker hub account with te credentials in .travis.yaml file
# usa dos etiquetas, latest y el GIT SHA que lo recupera de las variables de entorno de travis
docker build -t facundoalarcon/multi-client:latest -t facundoalarcon/multi-client:$SHA -f Dockerfile ./client
docker build -t facundoalarcon/multi-server:latest -t facundoalarcon/multi-server:$SHA -f Dockerfile ./server
docker build -t facundoalarcon/multi-worker:latest -t facundoalarcon/multi-worker:$SHA -f Dockerfile ./worker

docker push facundoalarcon/multi-client:latest
docker push facundoalarcon/multi-server:latest
docker push facundoalarcon/multi-worker:latest

docker push facundoalarcon/multi-client:$SHA
docker push facundoalarcon/multi-server:$SHA
docker push facundoalarcon/multi-worker:$SHA

# k8s commands
kubectl apply -f k8s
# esto es diferente a lo que haciamos en minikube
# seteamos cada deployment con a version del SHA no el latest (auque anteriomente creamos las 2 para que quede parejo siempre el latest)
# esto para saber que version se ejecuta en k8s
kubectl set image deployments/server-deployment server=facundoalarcon/multi-server:$SHA
kubectl set image deployments/client-deployment client=facundoalarcon/multi-client:$SHA
kubectl set image deployments/worker-deployment worker=facundoalarcon/multi-worker:$SHA