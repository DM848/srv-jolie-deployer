include "srv-interface.iol"
include "service-mesh.iol"
include "time.iol"
include "console.iol"
include "runtime.iol"
include "exec.iol"
include "jolie_deployer_interface.iol"
include "string_utils.iol"
include "json_utils.iol"
include "cloud_server_iface.iol"
include "srv-disk-writer.iol"

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
  Protocol: http {
    .format = "json";
    .method = "post"
  }
  Interfaces:
    User_Service_Interface,
    Jolie_Deployer_Interface,
    ServiceMeshInterface
}

outputPort Writer {
    Location: "socket://jolie-disk-writer:8020/"
    Protocol: http
    Interfaces: DiskWriterInterface
}


outputPort UserService {
    Protocol: http
    Interfaces: CloudServerIface
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

        // get free cpu
        exec@Exec("sh get_cpu.sh")(response);
        undef( response.exitCode);
        response.regex = "[ ]";
        split@StringUtils(response)(res);

        // getting string back as 1 1 1 1 1 1 1 900 940 870 893 640 940 778
        // find max free cpu
        max_free_cpu = 0;
        for ( i = 0, i < #res.result/2, i++){
          current_free = int(res.result[i])*1000 - int(res.result[i + #res.result/2]);

          if (current_free > max_free_cpu){
            max_free_cpu = current_free
          }
        };

        // get free memory
        exec@Exec("sh get_memory.sh")(response);
        undef(response.exitCode);
        response.regex = "[ ]";
        split@StringUtils(response)(res);

        // getting string back as 1188092Ki,1188092Ki,1188092Ki,1188092Ki,1188092Ki,1188092Ki,1188092Ki, 616Mi 506Mi 440Mi 660Mi 506Mi 506Mi 821000Ki
        // clean it first converting all to MB
        for ( i = 0, i < #res.result, i++){
          trim@StringUtils(res.result[i])(res.result[i]);
          length@StringUtils(res.result[i])(length);
          res.result[i].end = length - 2;
          res.result[i].begin = 0;
          substring@StringUtils(res.result[i])(cleaned);

          check = res.result[i];
          check.substring = "Ki";
          contains@StringUtils(check)(isKi);
          if (isKi){
            res.result[i] = int(double(cleaned) / 1000)
          } else {
            res.result[i] = int(cleaned)
          }
        };

        // find max free memory
        max_free_mem = 0;
        for ( i = 0, i < #res.result/2, i++){
          current_free = res.result[i] - res.result[i + #res.result/2];

          if (current_free > max_free_mem){
            max_free_mem = current_free
          }
        };

        // check that there is enough cpu
        if (max_free_cpu < request.cpu_min){
          answer.status = -1
        }
        // check that there is enough memory
        else if (max_free_mem < request.mem_min){
          answer.status = -1
        }
          //save the program, to be returned when the service asks for it
          // write file to disk, so it can be retrieved when cloud_server needs it
          // write in persistant storage
        else {
          writeProgram@Writer({.content = request.program, .filename = token + ".ol"})(write_resp);
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
    user: " + request.user + "
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
          stringhealthcheck +"
        resources:
          limits:
            cpu: " + double(request.cpu_max) / 1000 + "
            memory: "+ request.mem_max + "Mi
          requests:
            cpu: " + double(request.cpu_min) / 1000 +"
            memory: "+ request.mem_min + "Mi\n",
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
          println@Console("waiting for IP...")()
      };

      println@Console(matches.group[1])();

      substr = matches.group[1];
      substr.begin = 13;
      substr.end = 100;
      substring@StringUtils(substr)(PubIP);

      answer.ip = string(PubIP);
      answer.token = token;
      answer.status = 0 // no error

      /*
      //log action
      logentry.service = "jolie-deployer";
      logentry.info = "Loaded service, user: " + request.user + ", token: " + token;
      logentry.level = 5;
      set@Logger(logentry)()
      */
        }

    }]
    [statusUserPrograms(user)(response){
    //    response = "Not implemented yet"

        response = "";
        
        exec@Exec("kubectl get deployments -l user=" + user)(cmdresp);
        req = string(cmdresp);
        req.regex = "\n";
        split@StringUtils(req)(lines);
        
        //remove header line of output
        undef(lines.result[0]);
        
        for (line in lines.result)
        {
            undef(req);
            req = line;
            req.begin = 10;
            req.end = 46;
            
            substring@StringUtils(req)(line);
            println@Console("Deployment: " + string(line))();
            response = response + "Deployment: " + string(line) + "\n";
            
            exec@Exec("kubectl get pods -l app=" + string(line) + " ")(exec_resp);
            //println@Console(string(exec_resp))();
            
            undef(req);
            req = string(exec_resp);
            req.regex = "\n";
            split@StringUtils(req)(pod_lines);
            
            undef(pod_lines.result[0]);
            for (podline in pod_lines.result)
            {
                //println@Console("\tPOD: " + podline)();
                
                
                //Get name of pod
                undef(req);
                req = podline;
                req.regex = "\\s+";
                split@StringUtils(req)(podItems);
                println@Console("\tPod: Ready: " + podItems.result[1] + ", Status: " + podItems.result[2])();
                response = response + "\tPod: Ready: " + podItems.result[1] + ", Status: " + podItems.result[2] + "\n";
                
                exec@Exec("kubectl get pod " + podItems.result[0] + " -o wide")(wideoutput);
                //println@Console("\twide output: " + string(wideoutput))();
                //remove header line
                
                
                undef(req);
                req = string(wideoutput);
                req.regex = "\n";
                split@StringUtils(req)(wideLines);
                
                
                undef(req);
                req = string(wideLines.result[1]);
                req.regex = "\\s+";
                split@StringUtils(req)(wideItems);
                
                //println@Console("\nPid IP: " + wideItems.result[5])()
                ip = wideItems.result[5];
                UserService.location = "socket://" + ip + ":8000/";
                //exec@Exec("curl http://" + ip + ":8000/status")(curlresponse);
                //status@UserService()(user_status);
                
                println@Console("\t" + string(user_status))();
                response = response + "\t" + string(user_status) + "\n"
                
            };
            

            
            
            
            println@Console("--------------------------------------")();
            response = response + "--------------------------------------\n"
        };
        
        
        //str = string(cmdresp);
        //response = cmdresp

        }]

    [unload(request)(){

        println@Console("Im undeploying")();


        //NOTE maybe we should check that the program that should be undeployed
        // matches one that exists, so check the tags/ip in the deployment

        //tell the cloud_server it's going to be unloaded, but only one of them...
        UserService.location = "socket://service" + request.token + ":8000/";
        unload@UserService()(resp);
        
        println@Console("User program say: " + resp)();


        // remove program from persistant storage
        deleteProgram@Writer(request.token)(storage_response);
        println@Console(storage_response)();

        //undeploy from cluster
        exec@Exec("kubectl delete deployment deployment"+ request.token + " --grace-period=" + request.gracePeriod)();
        exec@Exec("kubectl delete service service" + request.token)()
    }]

    [ health() ( resp ) {
      resp = "Service alive and reachable"
    }]

    [getProgram(token)(program){
        println@Console("some user service is asking for a program")();

        //readFile@File( { .filename = token + ".ol" } )( program )
        getProgram@Writer(token)(program)

    }]
}
