

### What network range are the nodes in the cluster part of?
    
```bash
$ kubectl get nodes -o wide
NAME           STATUS   ROLES    AGE     VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION       CONTAINER-RUNTIME
controlplane   Ready    master   6m19s   v1.19.0   172.17.0.15   <none>        Ubuntu 18.04.5 LTS   4.15.0-122-generic   docker://19.3.13
node01         Ready    <none>   5m45s   v1.19.0   172.17.0.16   <none>        Ubuntu 18.04.5 LTS   4.15.0-122-generic   docker://19.3.13

$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: ens3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 02:42:ac:11:00:0f brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.15/16 brd 172.17.255.255 scope global ens3
       valid_lft forever preferred_lft forever
    inet6 fe80::42:acff:fe11:f/64 scope link 
       valid_lft forever preferred_lft forever
```


### What is the range of IP addresses configured for PODs on this cluster?
    
    
```bash
$ kubectl run nginx --image=nginx
pod/nginx created
controlplane $ kubectl get pods -o wide
NAME    READY   STATUS              RESTARTS   AGE   IP       NODE     NOMINATED NODE   READINESS GATES
nginx   0/1     ContainerCreating   0          7s    <none>   node01   <none>           <none>
controlplane $ kubectl get pods -o wide
NAME    READY   STATUS    RESTARTS   AGE   IP          NODE     NOMINATED NODE   READINESS GATES
nginx   1/1     Running   0          19s   10.32.0.4   node01   <none>           <none>
```


### What is the IP Range configured for the services within the cluster?
    
```bash
$ kubectl get service -o wide
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE   SELECTOR
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   16m   <none>

controlplane $ cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep service
    - --service-account-key-file=/etc/kubernetes/pki/sa.pub
    - --service-cluster-ip-range=10.96.0.0/12
```


### How many kube-proxy pods are deployed in this cluster
    
    
```bash
$ kubectl get pods -n kube-system | grep proxy
kube-proxy-mttb9                       1/1     Running   0          18m
kube-proxy-xdkcx                       1/1     Running   0          18m

$ kubectl logs -f kube-proxy-mttb9 -n kube-system
I0213 17:49:08.280115       1 node.go:136] Successfully retrieved node IP: 172.17.0.16
I0213 17:49:08.280369       1 server_others.go:111] kube-proxy node IP is an IPv4 address (172.17.0.16), assume IPv4 operation
W0213 17:49:08.518720       1 server_others.go:579] Unknown proxy mode "", assuming iptables proxy
I0213 17:49:08.518791       1 server_others.go:186] Using iptables Proxier.
I0213 17:49:08.519025       1 server.go:650] Version: v1.19.0
I0213 17:49:08.519331       1 conntrack.go:100] Set sysctl 'net/netfilter/nf_conntrack_max' to 131072
I0213 17:49:08.519348       1 conntrack.go:52] Setting nf_conntrack_max to 131072
I0213 17:49:08.519572       1 conntrack.go:83] Setting conntrack hashsize to 32768
I0213 17:49:08.525209       1 conntrack.go:100] Set sysctl 'net/netfilter/nf_conntrack_tcp_timeout_established' to 86400
I0213 17:49:08.525276       1 conntrack.go:100] Set sysctl 'net/netfilter/nf_conntrack_tcp_timeout_close_wait' to 3600
I0213 17:49:08.525676       1 config.go:315] Starting service config controller
I0213 17:49:08.525686       1 shared_informer.go:240] Waiting for caches to sync for service config
I0213 17:49:08.525708       1 config.go:224] Starting endpoint slice config controller
I0213 17:49:08.525712       1 shared_informer.go:240] Waiting for caches to sync for endpoint slice config
I0213 17:49:08.625872       1 shared_informer.go:247] Caches are synced for endpoint slice config 
I0213 17:49:08.625874       1 shared_informer.go:247] Caches are synced for service config 
```