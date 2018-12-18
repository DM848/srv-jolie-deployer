include "console.iol"
include "time.iol"

execution { sequential }

interface MyIface {
RequestResponse:
  print(void)(string),
  crash(void)(void)
}

inputPort MyInput {
Location: "socket://localhost:4000/"
Protocol: http {.format = "raw"}
Interfaces: MyIface
}

interface Health {
RequestResponse:
  health(void)(string)
}

inputPort Health {
Location: "socket://localhost:4001/"
Protocol: http {.format = "raw"/*; .statusCode -> statusCode*/}
Interfaces: Health
}

init
{
    global.health = "true"
}

main
{
  [ print()( response ) {
    response = "This is from server"
  } ]
  
  
  [crash()(){
      while(true)
      {
          println@Console("Staying busy - doing deadlocks")()
      }
  }
  
  ]

  [health()(resp)
  {
    resp = "true"
  } ]
}
