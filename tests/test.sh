#!/bin/sh

echo "Running test_deploy_service"
echo "Loading service user_print..."
resp=$(jolie load.ol user_server.ol 1 0)
