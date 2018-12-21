
execution
{
    sequential
}

interface PrintInterface {
    RequestResponse: print( void )( string )
}

inputPort PrintService
{
    Location: "socket://localhost:4000/"
    Protocol: http {.format = "json"}
    Interfaces: PrintInterface
}


main
{
    [print()(response)
    {
        response = "This is from server"
    }]
}
