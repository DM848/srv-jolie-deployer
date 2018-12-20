include "console.iol"
include "../jolie_deployer_interface.iol"



outputPort JolieDeployer {
Location: "socket://35.228.143.225:80/api/jolie-deployer/"
// Location: "socket://localhost:8000/"
Protocol: http
Interfaces: Jolie_Deployer_Interface
}




main{

    request.token = args[0];
    request.ip = "asdf";
    request.user = "joel";
    request.gracePeriod = 5;

    unload@JolieDeployer(request)()


}
