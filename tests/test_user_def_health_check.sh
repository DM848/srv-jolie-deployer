#!/bin/bash


resp=$(jolie load.ol crashtest.ol 1 1)
#resp=$(echo "35.228.186.130 3aaad5a3-b361-489b-8ff1-93b39742569b")
stringarray=($resp)
#echo ${stringarray[0]}
#echo ${stringarray[1]}
ip=${stringarray[0]}
token=${stringarray[1]}
echo $token


message=$(curl http://$ip:4000/print 2> /dev/null)
#echo http://$ip:400/print
echo $message


if [ "$message" == "This is from server" ]; then 
    echo "Message was equal" 
    ret=0
else 
    echo "Message not equal"
    ret=1
fi

sleep 3

message=$(curl http://$ip:4000/crash 2> /dev/null)

echo "crashing server"
sleep 60

message=$(curl http://$ip:4000/print --max-time 5 2> /dev/null)

jolie unload.ol $token

if [ "$message" == "This is from server" ]; then 
    echo "Service up again" 
    exit $ret;
else 
    echo "Service still down!"
    exit 1;
fi

