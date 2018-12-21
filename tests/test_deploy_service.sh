#!/bin/bash

echo "Running test_deploy_service"
echo "Loading service user_print..."
resp=$(jolie load.ol user_server.ol 1 0)
#resp=$(echo "35.228.186.130 3aaad5a3-b361-489b-8ff1-93b39742569b")
stringarray=($resp)
#echo ${stringarray[0]}
#echo ${stringarray[1]}
ip=${stringarray[0]}
token=${stringarray[1]}
echo $token

#start="http://"
#end=":400/print"
#fullstr="$start$ip$end"
#echo $fullstr
#token=$(jolie load.ol testserver.ol)
#echo $token

message=$(curl http://$ip:4000/print 2> /dev/null | grep -o "This is from server") 
#echo http://$ip:400/print
echo $message
sleep 3
jolie unload.ol $token

if [ "$message" == "This is from server" ]; then
    echo "Message was equal"
    ret=0
else
    echo "Message not equal"
    ret=1
fi

sleep 3

message=$(curl http://$ip:4000/print --max-time 5 2> /dev/null | grep -o "This is from server")

if [ "$message" != "This is from server" ]; then
    echo "Service undeployed"
    exit $ret;
else
    echo "Message not undeployed!"
    exit 1;
fi
