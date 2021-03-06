type UserLoadRequest:void {
  .user:string
  .name:string
  .healthcheck:bool
  .program:string
  .replicas:int
  .ports[1, *]: int
  .cpu_min: int
  .cpu_max: int
  .mem_min: int
  .mem_max: int
}

type UserUnloadRequest:void {
    .user:string
    .token:string
    .ip?:string
    .gracePeriod:int
}

type UserLoadResponse:void {
    .ip?:string
    .token?:string
    .status:int
}

interface Jolie_Deployer_Interface
{
    RequestResponse:
      load(UserLoadRequest)(UserLoadResponse),
      unload(UserUnloadRequest)(void),
      statusUserPrograms(string)(any)   //used to se the status of a users program
}

interface User_Service_Interface  //This is used by a user jolie service, to get the program
{
    RequestResponse:
        getProgram(string)(undefined)
}
