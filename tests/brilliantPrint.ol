include "console.iol"
include "time.iol"

execution { sequential }

interface MyIface {
RequestResponse:
  currentTime(void)(undefined)
}

inputPort MyInput {
Location: "socket://localhost:4000/"
Protocol: http {.format = "raw"}
Interfaces: MyIface
}

interface Health {
RequestResponse:
  health(void)(void)
}

inputPort Health {
Location: "socket://localhost:4001/"
Protocol: http {.format = "raw"; .statusCode -> statusCode}
Interfaces: Health
}


main
{
  [ currentTime()( response ) {
    getCurrentDateTime@Time()( response )
  } ]

  [health()()
  {
    println@Console("I'm alive")()
  } ]
}
