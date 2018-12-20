#!/bin/sh

docker-compose build --parallel
docker-compose push

kubectl delete service jolie-deployer
kubectl delete deployment jolie-deployer

kubectl apply -f k8s.yaml