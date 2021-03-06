include "../jolie_deployer_interface.iol"

// JSend is the json format used by the ACL to standarise all output to simplify system integration for the dashboard
type JSendLoad:void {
    .status: string
    .data?: UserLoadResponse
    .message?: string
    .http_code?: int
}
type JSendUnload:void {
    .status: string
    .data?: UserUnloadRequest
    .message?: string
    .http_code?: int
}

interface JDClientInterface
{
    RequestResponse:
        load(UserLoadRequest)(undefined),
        unload(UserUnloadRequest)(undefined),
        statusUserPrograms(string)(undefined)
}

outputPort JolieDeployer {
    Location: "socket://35.228.7.206:8888/api/jolie-deployer/"
    Protocol: http {
        .format = "json";
        .compression = false
     }
    Interfaces: JDClientInterface
}