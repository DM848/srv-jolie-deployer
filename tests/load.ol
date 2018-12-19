include "console.iol"
include "../jolie_deployer_interface.iol"
include "file.iol"
include "json_utils.iol"


outputPort JolieDeployer {
Location: "socket://35.228.143.225:80/api/jolie-deployer/"
//Location: "socket://localhost:8000/"
Protocol: http
Interfaces: Jolie_Deployer_Interface
}


main
{

    //read program from file, put in variable program
    readFile@File( { .filename = args[0] } )( program );
    
    replicas = 1;
    if (! is_defined(args[1]))
    {
        replicas = 1
    } else{
        replicas = int(args[1])
    };
    
    if (! is_defined(args[2]))
    {
        hc = false
    } else{
        if (args[2] == 1){
            hc = true
        } else{
            hc = false
        }
    };


    loadreq.user = "Kurt";
    loadreq.name = "kurtsPrinterService";
    loadreq.healthcheck = hc;
    loadreq.replicas = replicas;
    loadreq.ports[0] = 4000;
    
    getJsonString@JsonUtils(loadreq)(jsonstring);
    
    
    //load program in the cluster
    load@JolieDeployer({
      .manifest = jsonstring,
      .program = program,
      .ports[0] = 4000
    })(response);

    //print the returned IP address and token of the new service
    println@Console(response.ip + " " + response.token)()

}
