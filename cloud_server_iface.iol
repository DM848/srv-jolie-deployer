type LoadRequest:void {
  .program:string
}

interface CloudServerIface {
RequestResponse:
  unload(void)(any),
  status(void)(undefined)
}
