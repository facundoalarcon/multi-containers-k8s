docker build -t facundoalarcon/multi-client:latest -t facundoalarcon/multi-client:$SHA -f Dockerfile ./client
docker build -t facundoalarcon/multi-server:latest -t facundoalarcon/multi-server:$SHA -f Dockerfile ./server
docker build -t facundoalarcon/multi-worker:latest -t facundoalarcon/multi-worker:$SHA -f Dockerfile ./worker

docker push facundoalarcon/multi-client:latest
docker push facundoalarcon/multi-server:latest
docker push facundoalarcon/multi-worker:latest

docker push facundoalarcon/multi-client:$SHA
docker push facundoalarcon/multi-server:$SHA
docker push facundoalarcon/multi-worker:$SHA

kubectl apply -f k8s

kubectl set image deployments/server-deployment server=facundoalarcon/multi-server:$SHA
kubectl set image deployments/client-deployment client=facundoalarcon/multi-client:$SHA
kubectl set image deployments/worker-deployment worker=facundoalarcon/multi-worker:$SHA