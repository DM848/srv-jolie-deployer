type LoadRequest:void {
  .program:string
}

interface CloudServerIface {
RequestResponse:
  status(void)(undefined)
OneWay:
  unload(void)
}
