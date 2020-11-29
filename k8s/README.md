## minikube
```
minikube start

minikube ip

minikube dashboard

minikube delete
```
## Commands
```
kubectl apply -f <config-file / folder>

kubectl get pods

kubectl get services

kubectl describe <object-type> (<object-name>)

kubectl delete -f <config-file>

kubectl get deployments

kubectl get pods -o wide

kubectl set image <object-type> / <object-name> <container-name> = <new-image-to-use>

kubectl set image deployment/client-deployment client=facundoalarcon/multi-client:v1
```
## show minikube containers - docker-server change
```
eval $(minikube docker-env)
```
## troubleshooting
```
docker logs <container-id>

docker exect -it <containter-id> sh

kubectl logs <pod-id>

kubectl exec -it <pod-id> sh
```
## storage classess
```
kubectl get storageclass

kubectl describe storageclass

https://kubernetes.io/docs/concepts/storage/storage-classes/
```
## get persistent volumes (pv) and persistent volume claim (pvc)
```
kubectl get pv

kubectl get pvc
```
## create secrets

It is recommended to create it manually so as not to have a config file
```
kubectl create secret <type> <secret_name> --from-literal key=value
```
type:
- generic: indicates that we are storing an arbitrary number of key = value sets 
- docker-registry
- tls

### example
```
kubectl create secret generic pgpassword --from-literal PGPASSWORD=12345asdf

kubectl get secrets
```

```
env:
  - name: POSTGRES_PASSWORD     // value that expects the container to be passed to it (depends on the image, in the case of postgresql it expects that for the key)
    valueFrom:
      secretKeyRef:
        name: pgpassword        // name that was given to the secret when creating it
        key: PGPASSWORD         // key (with that it retrieves the value of the key)
```
### note

If some environment variable is in base64 / string string and others in number, an error will appear (then there you have to pass them all to string strings)
## delete node cache images
```
kubectl delete services <name>
kubectl delete pods <name>
```
### docker-server previously changed
```
docker system prune -a
```
### combine several files in one file
use three times - to separate the objects

```
object1
---
object2
```

## NGINX ingress-controller
https://github.com/kubernetes/ingress-nginx

minikube addons enable ingress

https://github.com/kubernetes/minikube/issues/8756

### notes (old)
```
apiVersion: networking.k8s.io/v1beta1
# UPDATE THE API
kind: Ingress
metadata:
  name: ingress-service
  annotations:
  ### annotations are essentially additional configuration options that are going to specify a type of top-level configuration around the Ingress object that is being created
    kubernetes.io/ingress.class: nginx
    ### the previous line indicates Ingress controller based on the nginx project
    nginx.ingress.kubernetes.io/use-regex: 'true'
    # ADD THIS LINE ABOVE
    nginx.ingress.kubernetes.io/rewrite-target: /$1
    ### The previous line indicates how our copy of nginx behaves (this is the / of nginx address)
    # UPDATE THIS LINE ABOVE
spec:
  rules:
    - http:
        paths:
          - path: /?(.*)
          # UPDATE THIS LINE ABOVE
            backend:
              serviceName: client-cluster-ip-service
              ### client-cluster-ip-service is the service name
              servicePort: 3000
          - path: /api/?(.*)
          # UPDATE THIS LINE ABOVE
            backend:
              serviceName: server-cluster-ip-service
              ### server-cluster-ip-service is the service name
              servicePort: 5000
```
### notes (new)
https://kubernetes.io/docs/concepts/services-networking/ingress/
https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-service
  annotations:
    kubernetes.io/ingress.class: 'nginx'
    nginx.ingress.kubernetes.io/use-regex: 'true'
    nginx.ingress.kubernetes.io/rewrite-target: /$1
spec:
  rules:
    - http:
        paths:
          - path: /?(.*)
            pathType: Prefix
            backend:
              service:
                name: client-cluster-ip-service
                port:
                  number: 3000
          - path: /api/?(.*)
            pathType: Prefix
            backend:
              service:
                name: server-cluster-ip-service
                port:
                  number: 5000
```