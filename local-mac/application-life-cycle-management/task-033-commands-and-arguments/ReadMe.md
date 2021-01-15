
### Commands And Arguments

- Suppose you want to run the following command in kubernetes pod: `ls -ltrh`
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ubuntu
spec:
  containers:
  - name: ubuntu-container
    image: ubuntu
    command: ["ls"]
    args: ["-ltrh"]
```

- Apply 
```bash
$ kubectl apply -f pod-ubuntu-ls.yaml  
pod/ubuntu created

$ kubectl get pods
NAME     READY   STATUS              RESTARTS   AGE
ubuntu   0/1     ContainerCreating   0          12s

$ kubectl get pods
NAME     READY   STATUS      RESTARTS   AGE
ubuntu   0/1     Completed   0          15s

$ kubectl get pods
NAME     READY   STATUS             RESTARTS   AGE
ubuntu   0/1     CrashLoopBackOff   1          17s

$ kubectl logs -f ubuntu                                         
total 48K
drwxr-xr-x   2 root root 4.0K Apr 15  2020 home
drwxr-xr-x   2 root root 4.0K Apr 15  2020 boot
lrwxrwxrwx   1 root root    8 Nov  6 01:21 sbin -> usr/sbin
lrwxrwxrwx   1 root root   10 Nov  6 01:21 libx32 -> usr/libx32
lrwxrwxrwx   1 root root    9 Nov  6 01:21 lib64 -> usr/lib64
lrwxrwxrwx   1 root root    9 Nov  6 01:21 lib32 -> usr/lib32
lrwxrwxrwx   1 root root    7 Nov  6 01:21 lib -> usr/lib
lrwxrwxrwx   1 root root    7 Nov  6 01:21 bin -> usr/bin
drwxr-xr-x   1 root root 4.0K Nov  6 01:21 usr
drwxr-xr-x   2 root root 4.0K Nov  6 01:21 srv
drwxr-xr-x   2 root root 4.0K Nov  6 01:21 opt
drwxr-xr-x   2 root root 4.0K Nov  6 01:21 mnt
drwxr-xr-x   2 root root 4.0K Nov  6 01:21 media
drwxr-xr-x   1 root root 4.0K Nov  6 01:25 var
drwx------   2 root root 4.0K Nov  6 01:25 root
drwxrwxrwt   2 root root 4.0K Nov  6 01:25 tmp
dr-xr-xr-x  13 root root    0 Jan 15 09:35 sys
drwxr-xr-x   1 root root 4.0K Jan 15 09:35 etc
dr-xr-xr-x 206 root root    0 Jan 15 09:35 proc
drwxr-xr-x   1 root root 4.0K Jan 15 09:35 run
drwxr-xr-x   5 root root  360 Jan 15 09:35 dev
```
- Note it goes to CrashLoopBack as the container exits after the command is run. And kubernetes tries to restart the pod as the container has exited


### What is the command used to run the pod 'ubuntu-sleeper'?
```bash
$ kubectl describe pod ubuntu-sleeper | grep -A 3 -i command
    Command:
      sleep
      4800
    State:          Running
```


### Create a pod with the ubuntu image to run a container to sleep for 5000 seconds.
```bash
controlplane $ kubectl apply -f ubuntu-sleeper-2.yaml
pod/ubuntu-sleeper-2 created
controlplane $ cat ubuntu-sleeper-2.yaml
apiVersion: v1
kind: Pod
metadata:
  name: ubuntu-sleeper-2
spec:
  containers:
  - name: ubuntu
    image: ubuntu
    command: ["sleep"]
    args: ["5000"]

##### OR 
controlplane $ cat ubuntu-sleeper-3.yaml
apiVersion: v1
kind: Pod
metadata:
  name: ubuntu-sleeper-3
spec:
  containers:
  - name: ubuntu
    image: ubuntu
    command:
      - "sleep"
      - "5000"
```

### Suppose you have the following Dockerfile given
```bash
controlplane $ cat Dockerfile
FROM python:3.6-alpine

RUN pip install flask

COPY . /opt/

EXPOSE 8080

WORKDIR /opt

ENTRYPOINT ["python", "app.py"]
```
What is the command used at startup

> python app.py

```bash
controlplane $ cat Dockerfile2
FROM python:3.6-alpine

RUN pip install flask

COPY . /opt/

EXPOSE 8080

WORKDIR /opt

ENTRYPOINT ["python", "app.py"]

CMD ["--color", "red"]
```
What is the command for above Dockerfile
> python app.py --color red


### Inspect the two files and tell what command is run at container startup?

```bash
controlplane $ cat Dockerfile2
FROM python:3.6-alpine

RUN pip install flask

COPY . /opt/

EXPOSE 8080

WORKDIR /opt

ENTRYPOINT ["python", "app.py"]

CMD ["--color", "red"]

controlplane $ cat webapp-color-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp-green
  labels:
      name: webapp-green
spec:
  containers:
  - name: simple-webapp
    image: kodekloud/webapp-color
    command: ["--color","green"]
controlplane $
```

>> --color green

### Inspect the two files and tell What command is run at container startup?

```bash
controlplane $ cat Dockerfile2
FROM python:3.6-alpine

RUN pip install flask

COPY . /opt/

EXPOSE 8080

WORKDIR /opt

ENTRYPOINT ["python", "app.py"]

CMD ["--color", "red"]

controlplane $ cat webapp-color-pod-2.yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp-green
  labels:
      name: webapp-green
spec:
  containers:
  - name: simple-webapp
    image: kodekloud/webapp-color
    command: ["python", "app.py"]
    args: ["--color", "pink"]
```

> python app.py --color pink


### Create a pod with the given specifications. By default it displays a 'blue' background. Set the given command line arguments to change it to 'green'
- Pod Name: webapp-green
- Image: kodekloud/webapp-color
- Command line arguments: --color=green

```bash
controlplane $ kubectl run nginx-pod --image=nginx --dry-run=client -o yaml > pod.yaml
controlplane $ vi pod.yaml
controlplane $ kubectl apply -f pod.yaml
pod/webapp-green created
controlplane $ cat pod.yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: my-pod
  name: webapp-green
spec:
  containers:
  - image: kodekloud/webapp-color
    name: webapp-green-container
    command: ["python", "app.py"]
    args: ["--color", "green"]    
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```