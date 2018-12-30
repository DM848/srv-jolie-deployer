#!/bin/bash


token=$(jolie load.ol crashtest.ol 1 1)

echo $token

sleep 16
message=$(curl http://35.228.7.206:8888/script/$token/print 2> /dev/null | grep -o "This is from server") 

#echo http://$ip:400/print
echo $message


if [ "$message" == "This is from server" ]; then 
    echo "Message was equal" 
    ret=0
else 
    echo "Message not equal"
    ret=1
fi

sleep 12

message=$(curl http://35.228.7.206:8888/script/$token/print 2> /dev/null | grep -o "This is from server") 

echo "crashing server"
sleep 60

message=$(curl http://35.228.7.206:8888/script/$token/print 2> /dev/null | grep -o "This is from server") 

jolie unload.ol $token

if [ "$message" == "This is from server" ]; then 
    echo "Service up again" 
    exit $ret;
else 
    echo "Service still down!"
    exit 1;
fi

