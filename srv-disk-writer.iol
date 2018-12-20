include "file.iol"


interface DiskWriterInterface {
  RequestResponse:
    writeProgram(WriteFileRequest)(any),
    getProgram(string)(any)
}
