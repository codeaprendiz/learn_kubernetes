
### How many static pods exist in this cluster in all namespaces?

```bash
controlplane $ kubectl get pods --all-namespaces
NAMESPACE     NAME                                   READY   STATUS    RESTARTS   AGE
kube-system   etcd-controlplane                      1/1     Running   0          8m43s
kube-system   kube-apiserver-controlplane            1/1     Running   0          8m43s
kube-system   kube-controller-manager-controlplane   1/1     Running   0          8m43s
kube-system   kube-scheduler-controlplane            1/1     Running   0          8m43s

kube-system   coredns-f9fd979d6-ktrcd                1/1     Running   0          8m33s
kube-system   coredns-f9fd979d6-xs7vm                1/1     Running   0          8m33s
kube-system   kube-flannel-ds-amd64-7lms5            1/1     Running   0          8m33s
kube-system   kube-flannel-ds-amd64-gqt9g            1/1     Running   0          8m20s
kube-system   kube-proxy-g4bdq                       1/1     Running   0          8m20s
kube-system   kube-proxy-x2qz2                       1/1     Running   0          8m33s

controlplane $ pwd
/etc/kubernetes/manifests

controlplane $ ls
etcd.yaml  kube-apiserver.yaml  kube-controller-manager.yaml  kube-scheduler.yaml

## Therefore 4 static pods
## Note that static pods have -controlplane appended at the end of name
```

### Which of the pods in --all-namespaces is NOT deployed as a static pod?
- etcd
- coredns
- kube-apiserver
- kube-controller-manager
- kube-scheduler
- kube-proxy
```bash
## coredns
## kube-proxy
```

### On what nodes are the static pods created?
    
```bash
controlplane $ kubectl get pods --all-namespaces  -o wide
NAMESPACE     NAME                                   READY   STATUS    RESTARTS   AGE   IP            NODE           NOMINATED NODE   READINESS GATES
kube-system   coredns-f9fd979d6-ktrcd                1/1     Running   0          17m   10.244.0.2    controlplane   <none>           <none>
kube-system   coredns-f9fd979d6-xs7vm                1/1     Running   0          17m   10.244.0.3    controlplane   <none>           <none>
kube-system   etcd-controlplane                      1/1     Running   0          17m   172.17.0.19   controlplane   <none>           <none>
kube-system   kube-apiserver-controlplane            1/1     Running   0          17m   172.17.0.19   controlplane   <none>           <none>
kube-system   kube-controller-manager-controlplane   1/1     Running   0          17m   172.17.0.19   controlplane   <none>           <none>
kube-system   kube-flannel-ds-amd64-7lms5            1/1     Running   0          17m   172.17.0.19   controlplane   <none>           <none>
kube-system   kube-flannel-ds-amd64-gqt9g            1/1     Running   0          17m   172.17.0.23   node01         <none>           <none>
kube-system   kube-proxy-g4bdq                       1/1     Running   0          17m   172.17.0.23   node01         <none>           <none>
kube-system   kube-proxy-x2qz2                       1/1     Running   0          17m   172.17.0.19   controlplane   <none>           <none>
kube-system   kube-scheduler-controlplane            1/1     Running   0          17m   172.17.0.19   controlplane   <none>           <none>
```

### What is the path of the directory holding the static pod definition files?

```bash
controlplane $ ps -ef | grep kubelet | egrep "\-\-config"
root     16086     1  3 07:46 ?        00:00:10 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml --network-plugin=cni --pod-infra-container-image=k8s.gcr.io/pause:3.2

controlplane $ cat /var/lib/kubelet/config.yaml |  grep -i static
staticPodPath: /etc/kubernetes/manifests

controlplane $ ls /etc/kubernetes/manifests/
etcd.yaml  kube-apiserver.yaml  kube-controller-manager.yaml  kube-scheduler.yaml
```

### Create a static pod named static-busybox that uses the busybox image and the command sleep 1000
    
```bash
controlplane $ kubectl run static-busybox --image=busybox --command sleep 1000 --restart Never --dry-run=client -o yaml > static-busybox.yamlcontrolplane $ pwd
/etc/kubernetes/manifests
controlplane $ ls
etcd.yaml  kube-apiserver.yaml  kube-controller-manager.yaml  kube-scheduler.yaml  static-busybox.yaml
controlplane $ kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
static-busybox-controlplane   1/1     Running   0          11s
```

### Edit the image on the static pod to use busybox:1.28.4
```bash
controlplane $ vi static-busybox.yaml
controlplane $ cat static-busybox.yaml | grep -i image
    image: busybox:1.28.4
controlplane $ kubectl describe pod static-busybox-controlplane | grep -i image
    Image:         busybox:1.28.4
```

### We just created a new static pod named static-greenbox. Find it and delete it.

```bash
controlplane $ kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
static-busybox-controlplane   1/1     Running   0          5m5s
static-greenbox-node01        1/1     Running   0          4m10s
```

- that means pod is created on node01. Let's get its IP address

```bash
controlplane $ kubectl get node -o wide
NAME           STATUS   ROLES    AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION       CONTAINER-RUNTIME
controlplane   Ready    master   50m   v1.19.0   172.17.0.19   <none>        Ubuntu 18.04.5 LTS   4.15.0-122-generic   docker://19.3.13
node01         Ready    <none>   50m   v1.19.0   172.17.0.23   <none>        Ubuntu 18.04.5 LTS   4.15.0-122-generic   docker://19.3.13
```

- Let's try ssh into it
```bash
controlplane $ ssh node01
ssh: Could not resolve hostname node01: Temporary failure in name resolution
## that means its not added to host file

controlplane $ ssh 172.17.0.23
node01 $
```

- Let's see kubelet service and get the static pod file path
```bash
node01 $ ps -ef | grep kubelet | egrep "\--config"
root     16607     1  2 08:01 ?        00:00:09 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml --network-plugin=cni --pod-infra-container-image=k8s.gcr.io/pause:3.2

node01 $ cat /var/lib/kubelet/config.yaml | grep -i static
staticPodPath: /etc/just-to-mess-with-you

## LOL, NICE TRY
```

- Lets delete the file there
```bash
node01 $ cd /etc/just-to-mess-with-you
node01 $ ls
greenbox.yaml
node01 $ rm greenbox.yaml
node01 $ kubectl get pods
The connection to the server localhost:8080 was refused - did you specify the right host or port?
node01 $ exit
logout
Connection to 172.17.0.23 closed.
controlplane $ kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
static-busybox-controlplane   1/1     Running   0          10m
static-greenbox-node01        1/1     Running   0          9m41s

## WAIT WHAT ? Let's check again

controlplane $ ssh 172.17.0.23
node01 $ cd /etc/just-to-mess-with-you
node01 $ ls
node01 $ kubectl get pods
The connection to the server localhost:8080 was refused - did you specify the right host or port?
node01 $ exit
logout
Connection to 172.17.0.23 closed.
controlplane $ kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
static-busybox-controlplane   1/1     Running   0          11m

## Ah okay, that means it takes come time to get deleted :) 
```