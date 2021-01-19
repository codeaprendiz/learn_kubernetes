### InitContainers

In a multi-container pod, each container is expected to run a process 
that stays alive as long as the POD's lifecycle. For example in the multi-container pod 
that has a web application and logging agent, both the containers are expected to stay alive 
at all times. The process running in the log agent container is expected to stay alive as long 
as the web application is running. If any of them fails, the POD restarts.

But at times you may want to run a process that runs to completion in a container. 
For example a process that pulls a code or binary from a repository that will be used 
by the main web application. That is a task that will be run only  one time when the pod 
is first created. Or a process that waits  for an external service or database to be up 
before the actual application starts. That's where initContainers comes in.

An `initContainer` is configured in a pod like all other containers, 
except that it is specified inside a initContainers section,  like this:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
spec:
  containers:
  - name: myapp-container
    image: busybox:1.28
    command: ['sh', '-c', 'echo The app is running! && sleep 3600']
  initContainers:
  - name: init-myservice
    image: busybox
    command: ['sh', '-c', 'git clone <some-repository-that-will-be-used-by-application> ; done;']
```

- When a POD is first created the initContainer is run, and the process in the initContainer must run to a completion before the real container hosting the application starts.

- You can configure multiple such initContainers as well, like how we did for multi-pod containers. In that case each init container is run one at a time in sequential order.

- If any of the initContainers fail to complete, Kubernetes restarts the Pod repeatedly until the Init Container succeeds.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
spec:
  containers:
  - name: myapp-container
    image: busybox:1.28
    command: ['sh', '-c', 'echo The app is running! && sleep 3600']
  initContainers:
  - name: init-myservice
    image: busybox:1.28
    command: ['sh', '-c', 'until nslookup myservice; do echo waiting for myservice; sleep 2; done;']
  - name: init-mydb
    image: busybox:1.28
    command: ['sh', '-c', 'until nslookup mydb; do echo waiting for mydb; sleep 2; done;']
```

### Identify the pod that has an initContainer configured.

```bash
controlplane $ kubectl get pods
NAME    READY   STATUS    RESTARTS   AGE
blue    1/1     Running   0          57s
green   2/2     Running   0          58s
red     1/1     Running   0          58s
controlplane $ kubectl describe pod blue | grep -i init
Init Containers:
  init-myservice:
  Initialized       True
  Normal  Created    2m23s  kubelet, node01    Created container init-myservice
  Normal  Started    2m23s  kubelet, node01    Started container init-myservice
controlplane $ kubectl describe pod green | grep -i init
  Initialized       True
controlplane $ kubectl describe pod red | grep -i init
  Initialized       True
```

### What is the image used by the initContainer on the blue pod?

```bash
controlplane $ kubectl describe pod blue | grep -i "init containers" -A 5
Init Containers:
  init-myservice:
    Container ID:  docker://0e4a5a52ea23b5d80f769cb22c5df81d43f744674fd042f6a67d57ffe2e347cb
    Image:         busybox
    Image ID:      docker-pullable://busybox@sha256:c5439d7db88ab5423999530349d327b04279ad3161d7596d2126dfb5b02bfd1f
    Port:          <none>
```


### What is the state of the initContainer on pod blue

```bash
ontrolplane $ kubectl describe pod blue | grep -i "init containers" -A 12
Init Containers:
  init-myservice:
    Container ID:  docker://0e4a5a52ea23b5d80f769cb22c5df81d43f744674fd042f6a67d57ffe2e347cb
    Image:         busybox
    Image ID:      docker-pullable://busybox@sha256:c5439d7db88ab5423999530349d327b04279ad3161d7596d2126dfb5b02bfd1f
    Port:          <none>
    Host Port:     <none>
    Command:
      sh
      -c
      sleep 5
    State:          Terminated
      Reason:       Completed
```

### We just created a new app named purple. How many initContainers does it have?

```bash
controlplane $ kubectl describe pod purple | grep -i "init containers" -A 20
Init Containers:
  warm-up-1:
    Container ID:  docker://43aeab0c84d0ee23e0696c45b45b8eded630d71330fe23d6155c0d5e5fb8b2b0
    Image:         busybox:1.28
    Image ID:      docker-pullable://busybox@sha256:141c253bc4c3fd0a201d32dc1f493bcf3fff003b6df416dea4f41046e0f37d47
    Port:          <none>
    Host Port:     <none>
    Command:
      sh
      -c
      sleep 600
    State:          Running
      Started:      Tue, 19 Jan 2021 10:15:24 +0000
    Ready:          False
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-kp8m5 (ro)
  warm-up-2:
    Container ID:
    Image:         busybox:1.28
```


### How long after the creation of the POD will the application come up and be available to users?
- check the sleep time of init containers in this case
```bash
controlplane $ kubectl describe pod purple | grep sleep
      sleep 600
      sleep 1200
      echo The app is running! && sleep 3600
```

### Update the pod red to use an initContainer that uses the busybox image and sleeps for 20 seconds

```bash
controlplane $ kubectl get pod red -o yaml > pod.yaml
controlplane $ kubectl delete -f pod.yaml
pod "red" deleted

controlplane $ kubectl apply -f pod.yaml
pod/red created

controlplane $ cat pod.yaml | grep -i "initContainers" -A 3
  initContainers:
  - name: init-myservice
    image: busybox
    command: ['sh', '-c', 'echo The app is running! && sleep 20']
```

### A new application orange is deployed. There is something wrong with it. Identify and fix the issue.

```bash
controlplane $ kubectl logs -f orange
Error from server (BadRequest): container "orange-container" in pod "orange" is waiting to start: PodInitializing

controlplane $ kubectl get pod orange -o yaml > pod.yaml

controlplane $ cat pod.yaml | grep -i initContainers -A 5
  initContainers:
  - command:
    - sh
    - -c
    - sleeeep 2;
    image: busybox

controlplane $ kubectl delete -f pod.yaml
pod "orange" deleted

## fix the sleep command in file
controlplane $ cat pod.yaml | grep -i initContainers -A 5
  initContainers:
  - command:
    - sh
    - -c
    - sleep 2;
    image: busybox

controlplane $ kubectl apply -f pod.yaml
pod/orange created
```