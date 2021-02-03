
### What is the user used to execute the sleep process within the 'ubuntu-sleeper' pod?

- in the current(default) namespace
  
```bash
controlplane $ kubectl exec ubuntu-sleeper -- whoami
root
```


### Edit the pod 'ubuntu-sleeper' to run the sleep process with user ID 1010.

[link](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)
    
Note: Only make the necessary changes. Do not modify the name or image of the pod.

Ensure that the security context field is not empty 

```bash
controlplane $ kubectl get pod ubuntu-sleeper -o yaml > pod.yaml

### the security context field will be by default empty

controlplane $ cat pod.yaml | grep security -A 2
  securityContext:
    runAsUser: 1010
```


### A Pod definition file named 'multi-pod.yaml' is given. With what user are the processes in the 'web' container started?

The pod is created with multiple containers and security contexts defined at the POD and Container level


```bash
controlplane $ cat multi-pod.yaml | egrep -i security -A 4 -B 4
kind: Pod
metadata:
  name: multi-pod
spec:
  securityContext:
    runAsUser: 1001
  containers:
  -  image: ubuntu
     name: web
     command: ["sleep", "5000"]
     securityContext:
      runAsUser: 1002

  -  image: ubuntu
     name: sidecar
```


### With what user are the processes in the 'sidecar' container started?
    
The pod is created with multiple containers and security contexts defined at the POD and Container level

```bash
### 1001 as it is done at the spec level
```


### Try to run the below command in the pod 'ubuntu-sleeper' to set the date. Are you allowed to set date on the POD?

```bash
controlplane $ kubectl exec -it ubuntu-sleeper -- date -s '19 APR 2012 11:14:00' 
date: cannot set date: Operation not permitted
Thu Apr 19 11:14:00 UTC 2012



command terminated with exit code 1
```

### Update pod 'ubuntu-sleeper' to run as Root user and with the 'SYS_TIME' capability.

Note: Only make the necessary changes. Do not modify the name of the pod.

Pod Name: ubuntu-sleeper

Image Name: ubuntu

SecurityContext: Capability SYS_TIME

```bash
controlplane $ kubectl get pod ubuntu-sleeper -o yaml > pod.yaml

controlplane $ cat pod.yaml | egrep -i "securityContext" -A 4 -B 4
--
  - command:
    - sleep
    - "4800"
    image: ubuntu
    securityContext:
      capabilities:
        add: ["NET_ADMIN", "SYS_TIME"]
    imagePullPolicy: Always
    name: ubuntu
```