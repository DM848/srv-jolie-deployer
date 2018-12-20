#!/bin/sh
# used_ki=$(kubectl describe nodes | grep -o -E "memory[ ]*[0-9]+Ki" | grep -o -E "[0-9]+Ki")
used=$(kubectl describe nodes | grep -o -E "memory[ ]*[0-9]+[MK]i" | grep -o -E "[0-9]+[MK]i")
total=$(kubectl get nodes -o jsonpath='{range .items[*]}{.status.allocatable.memory} {end}')
echo $total $used
   