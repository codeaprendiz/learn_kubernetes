## Cluster Upgrade

### This lab tests your skills on upgrading a kubernetes cluster. We have a production cluster with applications running on it. Let us explore the setup first.
  
- What is the current version of the cluster?

```bash
controlplane $ kubectl get node
NAME           STATUS   ROLES    AGE     VERSION
controlplane   Ready    master   8m11s   v1.18.0
node01         Ready    <none>   7m39s   v1.18.0
```


### How many nodes can host workloads in this cluster?
    
- Inspect the applications and taints set on the nodes.

```bash
controlplane $ kubectl describe node controlplane | grep -i taint
Taints:             <none>
controlplane $ kubectl describe node node01 | grep -i taint
Taints:             <none>
```

### How many applications are hosted on the cluster?
  
- Count the number of deployments.

```bash
controlplane $ kubectl get deployments
NAME   READY   UP-TO-DATE   AVAILABLE   AGE
blue   5/5     5            5           13m
red    2/2     2            2           13m
```

### What nodes are the pods hosted on?
    
```bash
controlplane $ kubectl get pods -o wide --no-headers=true | awk {'print $7'} | uniq
node01
```


### You are tasked to upgrade the cluster. User's accessing the applications must not be impacted. And you cannot provision new VMs. What strategy would you use to upgrade the cluster?

- Upgrade one node at a time while moving workloads to other.

### What is the latest stable version available for upgrade?
    
- Use kubeadm tool

```bash
controlplane $ kubeadm upgrade plan
.
COMPONENT            CURRENT   AVAILABLE
API Server           v1.18.0   v1.18.15
Controller Manager   v1.18.0   v1.18.15
Scheduler            v1.18.0   v1.18.15
Kube Proxy           v1.18.0   v1.18.15
CoreDNS              1.6.7     1.6.7
Etcd                 3.4.3     3.4.3-0

You can now apply the upgrade by executing the following command:

        kubeadm upgrade apply v1.18.15
```


### We will be upgrading the master node first. Drain the master node of workloads and mark it UnSchedulable

```bash
controlplane $ kubectl drain controlplane --ignore-daemonsets
node/controlplane cordoned
WARNING: ignoring DaemonSet-managed Pods: kube-system/kube-flannel-ds-amd64-4plkl, kube-system/kube-keepalived-vip-vff7m, kube-system/kube-proxy-h9bcg
evicting pod default/blue-8455cd8cd7-tmsvk
evicting pod default/blue-8455cd8cd7-fqsz8evicting pod default/blue-8455cd8cd7-hdvjv
evicting pod default/blue-8455cd8cd7-lcbgc
evicting pod default/red-59d898f784-t5src
evicting pod default/blue-8455cd8cd7-wd8g8
evicting pod default/red-59d898f784-blfx7
evicting pod kube-system/coredns-66bff467f8-87kss
evicting pod kube-system/coredns-66bff467f8-sfv25
evicting pod kube-system/katacoda-cloud-provider-69dc659fc-2z6l2
I0122 15:40:56.209205    8518 request.go:621] Throttling request took 1.171958663s, request: GET:https://172.17.0.46:6443/api/v1/namespaces/default/pods/blue-8455cd8cd7-hdvjv
pod/katacoda-cloud-provider-69dc659fc-2z6l2 evicted
pod/blue-8455cd8cd7-lcbgc evicted
pod/blue-8455cd8cd7-tmsvk evictedpod/red-59d898f784-blfx7 evicted
pod/red-59d898f784-t5src evicted
pod/blue-8455cd8cd7-wd8g8 evicted
pod/blue-8455cd8cd7-fqsz8 evicted
pod/blue-8455cd8cd7-hdvjv evicted
pod/coredns-66bff467f8-87kss evicted
pod/coredns-66bff467f8-sfv25 evicted
node/controlplane evicted
controlplane $
```

### Upgrade the master/controlplane components to exact version v1.19.0
    
- Upgrade kubeadm tool (if not already), then the master components, and finally the kubelet. 
- Practice referring to the kubernetes documentation page. 
- Note: While upgrading kubelet, if you hit dependency issue while running the apt-get upgrade kubelet command, use the apt install kubelet=1.19.0-00 command instead

```bash
controlplane $ sudo apt update
controlplane $ apt-get upgrade kubelet
controlplane $ apt install kubelet=1.19.0-00
controlplane $ kubeadm upgrade apply v.1.19.0
controlplane $ apt install kubeadm=1.19.0-00
controlplane $ kubeadm upgrade apply v1.19.0
controlplane $ kubectl version --short
Client Version: v1.20.2
Server Version: v1.19.0
```  
   
### Mark the master/controlplane node as "Schedulable" again
    
```bash
controlplane $ kubectl uncordon controlplane
node/controlplane already uncordoned
```


### Next is the worker node. Drain the worker node of the workloads and mark it UnSchedulable

- Next is the worker node. Drain the worker node of the workloads and mark it UnSchedulable

```bash
controlplane $ kubectl drain node01 --ignore-daemonsets
node/node01 already cordoned
WARNING: ignoring DaemonSet-managed Pods: kube-system/kube-flannel-ds-amd64-6khwh, kube-system/kube-keepalived-vip-b67nx, kube-system/kube-proxy-sk2kr
evicting pod default/blue-8455cd8cd7-x44zx
evicting pod default/red-59d898f784-mm8ws
evicting pod kube-system/katacoda-cloud-provider-ff5bf677c-x254c
evicting pod default/blue-8455cd8cd7-7njxs
evicting pod default/blue-8455cd8cd7-djrp9
evicting pod default/blue-8455cd8cd7-ngj87
evicting pod default/red-59d898f784-whqm2
evicting pod kube-system/coredns-f9fd979d6-6pdqb
evicting pod default/blue-8455cd8cd7-zq44v
I0122 16:30:27.641206   10906 request.go:655] Throttling request took 1.148844687s, request: GET:https://172.17.0.11:6443/api/v1/namespaces/default/pods/blue-8455cd8cd7-djrp9
pod/blue-8455cd8cd7-ngj87 evicted
pod/katacoda-cloud-provider-ff5bf677c-x254c evicted
pod/blue-8455cd8cd7-djrp9 evicted
pod/blue-8455cd8cd7-7njxs evicted
pod/blue-8455cd8cd7-zq44v evicted
pod/red-59d898f784-whqm2 evicted
pod/coredns-f9fd979d6-6pdqb evicted
pod/blue-8455cd8cd7-x44zx evicted
pod/red-59d898f784-mm8ws evicted
node/node01 evicted
```

### Upgrade the worker node to the exact version v1.19.0
    
```bash
controlplane $ kubectl get nodes -o wide
NAME           STATUS                     ROLES    AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION       CONTAINER-RUNTIME
controlplane   Ready                      master   91m   v1.19.0   172.17.0.11   <none>        Ubuntu 18.04.5 LTS   4.15.0-122-generic   docker://19.3.13
node01         Ready,SchedulingDisabled   <none>   90m   v1.18.0   172.17.0.12   <none>        Ubuntu 18.04.5 LTS   4.15.0-122-generic   docker://19.3.13

controlplane $ ssh 172.17.0.12
Warning: Permanently added '172.17.0.12' (ECDSA) to the list of known hosts.
node01 $

node01 sudo apt update
node01 apt-get upgrade kubelet
node01 kubeadm upgrade apply v.1.19.0
node01 apt install kubeadm=1.19.0-00
node01 kubeadm upgrade apply v1.19.0
node01 $ kubeadm upgrade node
node01 $ apt install kubelet=1.19.0-00
```

### Remove the restriction and mark the worker node as schedulable again.
    
```bash
controlplane $ kubectl uncordon node01
node/node01 uncordoned
```