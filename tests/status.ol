include "console.iol"

include "JDport.ol"

main
{
    statusUserPrograms@JolieDeployer(args[0])(resp);
    println@Console("Status for programs started by user " + args[0] + ":\n" + resp)()
}