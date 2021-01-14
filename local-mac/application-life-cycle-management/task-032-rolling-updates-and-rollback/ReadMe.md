
### We have deployed a simple web application. Inspect the PODs and the Services

```bash
controlplane $ kubectl get podsNAME                        READY   STATUS    RESTARTS   AGE
frontend-7776cb7d57-5kdc7   1/1     Running   0          17s
frontend-7776cb7d57-p4bqw   1/1     Running   0          17s
frontend-7776cb7d57-ttzdw   1/1     Running   0          17s
frontend-7776cb7d57-wqlsk   1/1     Running   0          17s
controlplane $ kubectl get services
NAME             TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)          AGE
kubernetes       ClusterIP   10.96.0.1     <none>        443/TCP          13m
webapp-service   NodePort    10.107.82.3   <none>        8080:30080/TCP   24s
```

### Run the script named curl-test.sh to send multiple requests to test the web application. Take a note of the output.

```bash
controlplane $ ./curl-test.sh
Hello, Application Version: v1 ; Color: blue OK
Hello, Application Version: v1 ; Color: blue OK
```

### Inspect the deployment and identify the number of PODs deployed by it
```bash
$ kubectl get deployment
NAME       READY   UP-TO-DATE   AVAILABLE   AGE
frontend   4/4     4            4           11m
```

### What container image is used to deploy the applications?
```bash
$ kubectl describe deployment frontend | grep -i image
    Image:        kodekloud/webapp-color:v1
```

### Inspect the deployment and identify the current strategy
```bash
$ kubectl describe deployment frontend | grep -i strategy
StrategyType:           RollingUpdate
RollingUpdateStrategy:  25% max unavailable, 25% max surge
```

### Let us try that. Upgrade the application by setting the image on the deployment to 'kodekloud/webapp-color:v2'

- Do not delete and re-create the deployment. Only set the new image name for the existing deployment.

```bash
controlplane $ kubectl describe deployment frontend | grep -A 2 -i container
  Containers:
   simple-webapp:
    Image:        kodekloud/webapp-color:v1
$ kubectl set image deployment frontend simple-webapp=kodekloud/webapp-color:v2
deployment.apps/frontend image updated
```

### Run the script curl-test.sh again. Notice the requests now hit both the old and newer versions. However none of them fail.
```bash
controlplane $ ./curl-test.sh
Hello, Application Version: v2 ; Color: green OK
Hello, Application Version: v1 ; Color: green OK
Hello, Application Version: v2 ; Color: green OK
```

### Up to how many PODs can be down for upgrade at a time
    
- Consider the current strategy settings and number of PODs - 4

```bash
 kubectl describe deployment frontend | grep -i "max unavailable"
RollingUpdateStrategy:  25% max unavailable, 25% max surge
```

### Change the deployment strategy to 'Recreate'
    
- Do not delete and re-create the deployment. Only update the strategy type for the existing deployment.
    - Deployment Name: frontend
    - Deployment Image: kodekloud/webapp-color:v2
    - Strategy: Recreate
    
```bash
$ kubectl edit deployment frontend
deployment.apps/frontend edited

$ kubectl get deployment frontend -o yaml | grep -A 2 -i strategy
  strategy:
    type: Recreate
  template:
```

### Upgrade the application by setting the image on the deployment to 'kodekloud/webapp-color:v3'
```bash
$ kubectl set image deployment frontend simple-webapp=kodekloud/webapp-color:v3
deployment.apps/frontend image updated
```

### Run the script curl-test.sh again. Notice the failures. Wait for the new application to be ready. Notice that the requests now do not hit both the versions

```bash
controlplane $ ./curl-test.sh
Failed
Failed
Hello, Application Version: v3 ; Color: red OK
Hello, Application Version: v3 ; Color: red OK
```