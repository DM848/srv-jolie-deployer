type UserLoadRequest:void {
  .program: string
  .manifest: string
}

type UserUnloadRequest:void {
    .user:string
    .token:string
    .ip:string
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
