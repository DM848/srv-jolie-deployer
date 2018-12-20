#!/bin/sh
useds=$(kubectl describe nodes | grep -E "cpu[ ]*[0-9]+" | grep -o -E "cpu[ ]+[0-9]*" | grep -o -E "[0-9]*")
total=$(kubectl describe nodes | grep -E "cpu:[ ]*[0-9]+" | grep -v -E "cpu:[ ]*[0-9]+m" | grep -o -E "[0-9]*")
echo $total $useds
