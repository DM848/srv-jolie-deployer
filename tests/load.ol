include "console.iol"
include "file.iol"
include "json_utils.iol"

include "JDport.ol"
# include "JDport_localhost.ol"

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

    //load program in the cluster
    load@JolieDeployer({
      .user = "Kurt",
      .name = "kurtsPrinterService",
      .healthcheck = hc,
      .program = program,
      .replicas = replicas,
      .ports[0] = 4000,
      .cpu_min = 50,
      .cpu_max = 250,
      .mem_min = 100,
      .mem_max = 1000
    })(response);

    //print the returned IP address and token of the new service
    println@Console(response.ip + " " + response.token)()

}
