include "console.iol"
include "../jolie_deployer_interface.iol"

outputPort JolieDeployer {
Location: "socket://35.228.143.225:80/api/jolie-deployer/"
//Location: "socket://localhost:8000/"
Protocol: http {.format = "json"}
Interfaces: Jolie_Deployer_Interface
}

main
{
    statusUserPrograms@JolieDeployer(args[0])(resp);
    println@Console("Status for programs started by user " + args[0] + ":\n" + resp)()
}