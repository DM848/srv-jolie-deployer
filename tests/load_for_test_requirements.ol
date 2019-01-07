include "console.iol"
include "file.iol"
include "json_utils.iol"

include "JDport.ol"
// include "JDport_localhost.ol"

main
{

    //read program from file, put in variable program
    readFile@File( { .filename = args[0] } )( program );

    cpu_min = int(args[1]);
    cpu_max = int(args[2]);
    mem_min = int(args[3]);
    mem_max = int(args[4]);




    getJsonString@JsonUtils(loadreq)(jsonstring);


    //load program in the cluster
    load@JolieDeployer({
      .user = "Kurt",
      .name = "kurtsPrinterService",
      .healthcheck = true,
      .replicas = 1,
      .ports[0] = 8080,
      .cpu_min = cpu_min,
      .cpu_max = cpu_max,
      .mem_min = mem_min,
      .mem_max = mem_max,
      .program = program
    })(response);
    
    /*
    load@JolieDeployer({
      .user = "Kurt",
      .name = "kurtsPrinterService",
      .healthcheck = false,
      .program = program,
      .replicas = 1,
      .ports[0] = 8080,loadreq
      .cpu_min = 50,
      .cpu_max = 250,
      .mem_min = 100,
      .mem_max = 1000
    })(response);
    */

    //print the returned IP address and token of the new service
    println@Console(response.data.status + " " + response.data.token)()
}
