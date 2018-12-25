include "console.iol"

include "JDport.ol"
# include "JDport_localhost.ol"

main{

    request.token = args[0];
    request.ip = "asdf";
    request.user = "joel";
    request.gracePeriod = 5;

    unload@JolieDeployer(request)()
}
