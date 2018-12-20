#!/bin/bash

echo "Running test_deploy_service"
echo "Loading service user_print with high cpu requirements"
resp=$(jolie load_for_test_requirements.ol user_server.ol 1000 1000 100 200)
stringarray=($resp)
status=${stringarray[0]}
token=${stringarray[1]}
echo $status

if [ "$status" == "-1" ]; then
    echo "deployment failed as intended"
else
    echo "deployment did not failed as intended"
    sleep 3
    jolie unload.ol $token
    exit 1
fi

echo "Loading service user_print with high memory requirements"
resp=$(jolie load_for_test_requirements.ol user_server.ol 50 200 1000 1000)
stringarray=($resp)
status=${stringarray[0]}
token=${stringarray[1]}
echo $status

if [ "$status" == "-1" ]; then
    echo "deployment failed as intended"
else
    echo "deployment did not failed as intended"
    sleep 3
    jolie unload.ol $token
    exit 1
fi


echo "Loading service user_print with normal cpu requirements"
resp=$(jolie load_for_test_requirements.ol user_server.ol 50 200 100 200)
stringarray=($resp)
status=${stringarray[0]}
token=${stringarray[1]}
echo $status

if [ "$status" == "-1" ]; then
    echo "deployment did not succeeded as intended"
    exit 1
else
    echo "deployment did succeeded as intended"
    sleep 3
    jolie unload.ol $token
fi

echo "Loading service user_print with normal memory requirements"
resp=$(jolie load_for_test_requirements.ol user_server.ol 50 200 100 200)
stringarray=($resp)
status=${stringarray[0]}
token=${stringarray[1]}
echo $status

if [ "$status" == "-1" ]; then
    echo "deployment did not succeeded as intended"
    exit 1
else
    echo "deployment did succeeded as intended"
    sleep 3
    jolie unload.ol $token
fi
exit 0
