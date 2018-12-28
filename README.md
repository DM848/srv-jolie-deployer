# srv-jolie-deployer


## User scripts
Any script deployed is given a publicly accessible endpoint in the format `/script/<token>/` where `<token>` is the response from the deployment (load).

However, to make your methods/functions accessible through this endpoint; you must implement them on port 8080. You are free to use any ports you want. But for publicly accessible endpoints you must use port 8080.