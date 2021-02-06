

### What is the network interface configured for cluster connectivity on the master node?

```bash
controlplane $ ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: ens3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 02:42:ac:11:00:15 brd ff:ff:ff:ff:ff:ff
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN mode DEFAULT group default 
    link/ether 02:42:8c:ac:bd:e2 brd ff:ff:ff:ff:ff:ff
4: cni0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 0a:d2:20:0d:51:5f brd ff:ff:ff:ff:ff:ff
5: vethcfaf81f2@if3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master cni0 state UP mode DEFAULT group default 
    link/ether 36:d2:ba:62:05:cf brd ff:ff:ff:ff:ff:ff link-netnsid 0
6: veth6dc8ac71@if3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master cni0 state UP mode DEFAULT group default 
    link/ether 72:ee:36:90:17:99 brd ff:ff:ff:ff:ff:ff link-netnsid 1
```


### What is the network interface configured for cluster connectivity on the master node?



```bash
$ ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: ens3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 02:42:ac:11:00:15 brd ff:ff:ff:ff:ff:ff
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN mode DEFAULT group default 
    link/ether 02:42:8c:ac:bd:e2 brd ff:ff:ff:ff:ff:ff
4: cni0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 0a:d2:20:0d:51:5f brd ff:ff:ff:ff:ff:ff
5: vethcfaf81f2@if3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master cni0 state UP mode DEFAULT group default 
    link/ether 36:d2:ba:62:05:cf brd ff:ff:ff:ff:ff:ff link-netnsid 0
6: veth6dc8ac71@if3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master cni0 state UP mode DEFAULT group default 
    link/ether 72:ee:36:90:17:99 brd ff:ff:ff:ff:ff:ff link-netnsid 1

## ens3
```

### What is the IP address assigned to the master node on this interface?
    
```bash
controlplane $ ifconfig -a | grep ens3 -A 2
ens3: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 172.17.0.21  netmask 255.255.0.0  broadcast 172.17.255.255
        inet6 fe80::42:acff:fe11:15  prefixlen 64  scopeid 0x20<link>

controlplane $ kubectl get nodes -o wide
NAME           STATUS   ROLES    AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION       CONTAINER-RUNTIME
controlplane   Ready    master   73m   v1.18.0   172.17.0.21   <none>        Ubuntu 18.04.5 LTS   4.15.0-122-generic   docker://19.3.13
node01         Ready    <none>   72m   v1.18.0   172.17.0.25   <none>        Ubuntu 18.04.5 LTS   4.15.0-122-generic   docker://19.3.13
```


### What is the MAC address of the interface on the master node?
    
```bash
controlplane $ ifconfig -a | egrep ens3 -A 4 | egrep ether
        ether 02:42:ac:11:00:15  txqueuelen 1000  (Ethernet)
```

### What is the MAC address assigned to node01?
    
```bash
controlplane $ ssh node01 ifconfig ens3
Warning: Permanently added 'node01,172.17.0.25' (ECDSA) to the list of known hosts.
ens3: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 172.17.0.25  netmask 255.255.0.0  broadcast 172.17.255.255
        inet6 fe80::42:acff:fe11:19  prefixlen 64  scopeid 0x20<link>
        ether 02:42:ac:11:00:19  txqueuelen 1000  (Ethernet)
        RX packets 136298  bytes 155301021 (155.3 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 50435  bytes 5498608 (5.4 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```


### We use Docker as our container runtime. What is the interface/bridge created by Docker on this host?

```bash
$ ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: ens3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 02:42:ac:11:00:15 brd ff:ff:ff:ff:ff:ff
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN mode DEFAULT group default 
    link/ether 02:42:8c:ac:bd:e2 brd ff:ff:ff:ff:ff:ff
4: cni0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 0a:d2:20:0d:51:5f brd ff:ff:ff:ff:ff:ff
5: vethcfaf81f2@if3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master cni0 state UP mode DEFAULT group default 
    link/ether 36:d2:ba:62:05:cf brd ff:ff:ff:ff:ff:ff link-netnsid 0
6: veth6dc8ac71@if3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master cni0 state UP mode DEFAULT group default 
    link/ether 72:ee:36:90:17:99 brd ff:ff:ff:ff:ff:ff link-netnsid 1
```


### What is the state of the interface docker0?
    
```bash
### DOWN
```


### If you were to ping google from the master node, which route does it take?

- check the default route
    
```bash
controlplane $ ip route
default via 172.17.0.1 dev ens3 
10.244.0.0/24 dev cni0 proto kernel scope link src 10.244.0.1 
10.244.1.0/24 via 172.17.0.25 dev ens3 
172.17.0.0/16 dev ens3 proto kernel scope link src 172.17.0.21 
172.18.0.0/24 dev docker0 proto kernel scope link src 172.18.0.1 linkdown 
```

### What is the port the kube-scheduler is listening on in the master node?
    
```bash
$ netstat -anp | grep -i kube-scheduler
tcp        0      0 127.0.0.1:10259         0.0.0.0:*               LISTEN      2202/kube-scheduler 
tcp        0      0 172.17.0.21:53608       172.17.0.21:6443        ESTABLISHED 2202/kube-scheduler 
tcp        0      0 172.17.0.21:53456       172.17.0.21:6443        ESTABLISHED 2202/kube-scheduler 
tcp6       0      0 :::10251                :::*                    LISTEN      2202/kube-scheduler 
unix  2      [ ]         DGRAM                    24138    2202/kube-scheduler  @00020
```


### Notice that ETCD is listening on two ports. Which of these have more client connections established?

```bash
$ netstat -anp | grep etcd | grep LISTEN
tcp        0      0 172.17.0.21:2379        0.0.0.0:*               LISTEN      2185/etcd           
tcp        0      0 127.0.0.1:2379          0.0.0.0:*               LISTEN      2185/etcd           
tcp        0      0 172.17.0.21:2380        0.0.0.0:*               LISTEN      2185/etcd           
tcp        0      0 127.0.0.1:2381          0.0.0.0:*               LISTEN      2185/etcd  

$ netstat -anp | grep etcd | grep  ESTABLISHED | grep "127.0.0.1:2379" | egrep -v "49730" | wc -l
68
```