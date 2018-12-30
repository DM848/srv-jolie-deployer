#!/bin/bash

echo "Running test_deploy_service" 
echo "Loading service user_print..."
token=$(jolie load.ol user_server.ol 1 0)
echo $token
#resp=$(echo "35.228.186.130 3aaad5a3-b361-489b-8ff1-93b39742569b")

#stringarray=($resp)
#echo ${stringarray[0]}
#echo ${stringarray[1]}
#ip=${stringarray[0]}
#token=${stringarray[1]}
#echo $token

#start="http://"
#end=":400/print"
#fullstr="$start$ip$end"
#echo $fullstr
#token=$(jolie load.ol testserver.ol)
#echo $token

#message=$(curl http://$ip:4000/print 2> /dev/null | grep -o "This is from server")
 sleep 12
message=$(curl http://35.228.7.206:8888/script/$token/print 2> /dev/null | grep -o "This is from server") 
sleep 3
#echo http://$ip:400/print
echo $message
jolie unload.ol $token

if [ "$message" == "This is from server" ]; then
    echo "Message was equal"
    ret=0
else
    echo "Message not equal"
    ret=1
fi

sleep 60

newmessage=$(curl http://35.228.7.206:8888/script/$token/print 2> /dev/null | grep -o "This is from server") 
echo $newmessage
if [ "$newmessage" != "This is from server" ]; then
    echo "Service undeployed"
    exit $ret;
else
    echo "Message not undeployed!"
    exit 1;
fi
