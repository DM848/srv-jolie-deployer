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

// ############
// Logger
type LogEntry:void {
    .service: string // name of service inserting the log
    .info: string // what happened?
    .level: int // log level, info, debug, etc. use java log level
}

type Query:void {
  .id?: int
  .before?: string // TODO
  .after?: string // TODO
  .limit?: int
  .service?: string
}

interface LoggerInterface {
  RequestResponse:
    about(void)(string),
    get(Query)(undefined), // list
    set(LogEntry)(int) // returns entry id, otherwise -1
}

outputPort Logger {
    Location: "socket://logger:8888/"
    Interfaces: LoggerInterface
    Protocol: http
}
