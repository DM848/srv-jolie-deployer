#!/bin/bash


resp=$(jolie load.ol user_server.ol 3 0)

stringarray=($resp)


ip=${stringarray[0]}
token=${stringarray[1]}
echo $token


message=$(curl http://$ip:4000/print --max-time 5 2> /dev/null)
ret=0

echo $message


# One might think, that for i in {1..10} would be a prettier 
# way to write this. In that case, one would be correct!
for i in  1 2 3 4 5 6 7 8 9
do
{
    if [ "$message" == "This is from server" ]; then 
        echo "Message was equal" 
        ret=$(($ret + 0))
    else 
        echo "Message not equal"
        ret=1
    fi
}
done


jolie unload.ol $token
sleep 3

message=$(curl http://$ip:4000/print --max-time 5 2> /dev/null)

if [ "$message" != "This is from server" ]; then 
    echo "Service undeployed" 
    exit $ret;
else 
    echo "Message not undeployed!"
    exit 1;
fi