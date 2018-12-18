include "srv-interface.iol"
include "service-mesh.iol"
include "time.iol"
include "console.iol"
include "runtime.iol"
include "exec.iol"
include "jolie_deployer_interface.iol"
include "file.iol"
include "string_utils.iol"

// single is the default execution modality (so the execution construct can be omitted),
// which runs the program behaviour once. sequential, instead, causes the program behaviour
// to be made available again after the current instance has terminated. This is useful,
// for instance, for modelling services that need to guarantee exclusive access to a resource.
// Finally, concurrent causes a program behaviour to be instantiated and executed whenever its
// first input statement can receive a message.
//
// execution { single | concurrent | sequential }
execution { concurrent }

// The input port specifies how your service can be reached. However, since we use
// Docker containers, the port here should not be set as it is exposed in the Dockerfile.
inputPort JolieDeployerInput {
  Location: "socket://localhost:8000/"
  Protocol: http {.format = "raw"}
  Interfaces: 
    User_Service_Interface,
    Jolie_Deployer_Interface, 
    ServiceMeshInterface
}

// The init{} scope allows the specification of initialisation procedures (before the web server
// goes public). All the code specified within the init{} scope is executed only once, when
// the service is started.
init
{
    println@Console( "initialising jolie-deployer")()
}

// incomming requests
main
{
    [load(request)(answer){


        token = new;    //unique token that is used inside the cluster to
                        //identify this service + deployment

        //save the program, to be returned when the service asks for it
        writeFile@File({.content = request.program, .filename = token + ".ol"})();

        if (request.healthcheck)
        {
            stringhealthcheck =         
"        livenessProbe:
          exec:
            command:
            - /bin/sh
            - -c
            - /alive.sh
          initialDelaySeconds: 15
          periodSeconds: 10\n"
        }
        else
        {
            stringhealthcheck = ""
        };

        writeFile@File ({
      .content =
"apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment" + token + "
  labels:
    app: " + token + "
spec:
  replicas: " + request.replicas + "
  selector:
    matchLabels:
      app: " + token + "
  template:
    metadata:
      labels:
        app: " + token + "
    spec:
      containers:
      - name: " + token + "
        image: joelhandig/cloud_server:latest
        imagePullPolicy: Always
        env:
        - name: TOKEN
          value: " + token + "
        ports:
        - containerPort: 8000\n" + 
        stringhealthcheck, 
      .filename = "deployment.yaml"
    } )();

    serviceString =
"apiVersion: v1
kind: Service
metadata:
  name: service" + token + "
spec:
  ports:
  - name: health
    port: 4001
    targetPort: 4001
  - name: host
    port: 8000
    targetPort: 8000\n";
    for ( port in request.ports)
    {
        serviceString = serviceString +
"  - name: " + new + "
    port: "+ port +"
    targetPort: " + port + "\n"
};

    serviceString = serviceString +
"  selector:
    app: " + token + "
  type: LoadBalancer\n";

    writeFile@File({.content = serviceString, .filename = "service.yaml"})();


    //create new deployment and service
    exec@Exec("kubectl create -f deployment.yaml")(execResponse);
    println@Console(execResponse)();
    exec@Exec("kubectl create -f service.yaml")(execResponse);
    print@Console(execResponse)();



    //Following while-loop blocks until the kubernetes cluster
    //has allocated a new public ip. This usually takes 60 seconds

    matches = 0;
    while (matches == 0)
    {
        cmdstring = "kubectl describe service service" + token;
        exec@Exec(cmdstring)(response);


        item = string(response);
        item.regex = "(?s).*(Ingress:     [0-9]*.[0-9]*.[0-9]*.[0-9]*)(?s).*";

        match@StringUtils(item)(matches);

        sleep@Time(3000)();
        println@Console("wating for IP...")()
    };

    println@Console(matches.group[1])();

    substr = matches.group[1];
    substr.begin = 13;
    substr.end = 100;
    substring@StringUtils(substr)(PubIP);





    answer.ip = string(PubIP);
    answer.token = token

    /*
    //log action
    logentry.service = "jolie-deployer";
    logentry.info = "Loaded service, user: " + request.user + ", token: " + token;
    logentry.level = 5;
    set@Logger(logentry)()
    */

    }]
    
    [unload(request)(){

        println@Console("Im undeploying")();


        //NOTE maybe we should check that the program that should be undeployed
        // matches one that exists, so check the tags/ip in the deployment

        //undeploy from cluster
        exec@Exec("kubectl delete deployment deployment"+ request.token + " --grace-period=" + request.gracePeriod)();
        exec@Exec("kubectl delete service service" + request.token)()

        
    }]
    
    [ health() ( resp ) {
        resp = "Service alive and reachable"
    }]
    
    [getProgram(token)(program){
        println@Console("some user service is asking for a program")();

        readFile@File( { .filename = token + ".ol" } )( program )

    }]
}
