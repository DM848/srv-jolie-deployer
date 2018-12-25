include "console.iol"

include "JDport.ol"

main{

    request.token = args[0];
    request.ip = "asdf";
    request.user = "joel";
    request.gracePeriod = 5;

    unload@JolieDeployer(request)()
}
