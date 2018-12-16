// #########
// # Health check of jolie service
interface ServiceMeshInterface {
    RequestResponse: 
        health(void)(string)
}

// #########
// # Consul KV storage
type ConsulKey: void {
    .key: string
}

type ConsulResponse: void {
    .key: string
    .val: string
    .err: string
}

interface ConsulGetter {
    RequestResponse:
        get( ConsulKey )( ConsulResponse )
}

outputPort Consul {
    Location: "socket://consul-kv-jolie:8888/"
    Interfaces: ConsulGetter
    Protocol: http { .method = "get" }
}
