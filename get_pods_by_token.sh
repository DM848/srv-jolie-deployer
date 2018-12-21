#!/bin/sh
token=$1
pods=$(kubectl get pods -l app=$token -o jsonpath='{range .items[*]}{.status.podIP},{end}')
echo $pods
 