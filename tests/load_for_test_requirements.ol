include "console.iol"
include "file.iol"
include "json_utils.iol"

include "JDport.ol"
# include "JDport_localhost.ol"

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
      .loadreq.user = "Kurt",
      .loadreq.name = "kurtsPrinterService",
      .loadreq.healthcheck = true,
      .loadreq.replicas = 1,
      .loadreq.ports[0] = 4000,
      .loadreq.cpu_min = cpu_min,
      .loadreq.cpu_max = cpu_max,
      .loadreq.mem_min = mem_min,
      .loadreq.mem_max = mem_max,
      .program = program
    })(response);

    //print the returned IP address and token of the new service
    println@Console(response.status + " " + response.token)()
}
