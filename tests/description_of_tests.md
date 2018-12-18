### Following is a description of some tests that we want for our system

- Deploy a user service
	Should fail if an error code is returned from the deploy-service
	Should fail if no token is returned from the deploy-service

- Run depolyed user service
	User service has an associated test. Test should fail if associated test fails

- Undeploy a user service
	Should fail if deploy-service returns an error message.
	Should fail if service is still active.


### Following is a description of what the test 'test_deploy_service.sh' does
1. load service 'testserver.ol', save token i variable 'token'
2. call service 'testclient.ol', which uses the 'testserver.ol' that now is running in the cloud, and then prints some string returned from it
3. unload service using the token from point 1.
4. If string printed by 'testclient.ol' is as expected, return 0, otherwise return 1.

Note that test returns 0 on success, and 1 on failure. To see the return value of the latest command, you can run 'echo $?' in bash.