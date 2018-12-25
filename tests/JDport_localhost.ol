include "../jolie_deployer_interface.iol"

outputPort JolieDeployer {
    Location: "socket://localhost:8000/"
    Protocol: http {.format = "json"}
    Interfaces: Jolie_Deployer_Interface
}