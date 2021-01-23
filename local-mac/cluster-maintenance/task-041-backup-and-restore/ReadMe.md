### We have a working kubernetes cluster with a set of applications running. Let us first explore the setup.
    
- How many deployments exist in the cluster?

```bash
controlplane $ kubectl get deployments
NAME   READY   UP-TO-DATE   AVAILABLE   AGE
blue   3/3     3            3           45s
red    2/2     2            2           45s
```

### What is the version of ETCD running on the cluster?
    
- Check the ETCD Pod or Process

```bash
controlplane $ kubectl describe pod etcd-controlplane -n kube-system | grep -i image
    Image:         k8s.gcr.io/etcd:3.4.9-1

controlplane $ ETCDCTL_API=3 etcdctl version
etcdctl version: 3.4.13
API version: 3.4
```


### At what address do you reach the ETCD cluster from your master/controlplane node?
    
- Check the ETCD Service configuration in the ETCD POD

```bash
controlplane $ kubectl describe pod etcd-controlplane -n kube-system | grep -i listen-client-url
      --listen-client-urls=https://127.0.0.1:2379,https://172.17.0.5:2379
```

### Where is the ETCD server certificate file located?

- Note this path down as you will need to use it later

```bash
controlplane $ kubectl describe pod etcd-controlplane -n kube-system  | grep -i .crt
      --cert-file=/etc/kubernetes/pki/etcd/server.crt
      --peer-cert-file=/etc/kubernetes/pki/etcd/peer.crt
      --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
      --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
```

### The master nodes in our cluster are planned for a regular maintenance reboot tonight. 

- While we do not anticipate anything to go wrong, we are required to take the necessary 
  backups. 
- Take a snapshot of the ETCD database using the built-in snapshot functionality.
- Store the backup file at location /opt/snapshot-pre-boot.db

```bash
ETCDCTL_API=3 etcdctl \
--endpoints=https://[127.0.0.1]:2379 \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key \
snapshot save /opt/snapshot-pre-boot.db
```

### Wake up! We have a conference call! 
- After the reboot the master nodes came back online, but none of our applications are accessible. 
- Check the status of the applications on the cluster. What's wrong?
  
```bash
controlplane $ kubectl get pods --all-namespaces
NAMESPACE     NAME                                   READY   STATUS    RESTARTS   AGE
kube-system   coredns-f9fd979d6-4nx4p                1/1     Running   0          31m
kube-system   coredns-f9fd979d6-fxzw9                1/1     Running   0          31m
kube-system   etcd-controlplane                      1/1     Running   0          31m
kube-system   kube-apiserver-controlplane            1/1     Running   0          31m
kube-system   kube-controller-manager-controlplane   1/1     Running   0          31m
kube-system   kube-flannel-ds-amd64-xc2cm            1/1     Running   0          30m
kube-system   kube-flannel-ds-amd64-z94jf            1/1     Running   0          31m
kube-system   kube-proxy-84d2s                       1/1     Running   0          31m
kube-system   kube-proxy-hfpdv                       1/1     Running   0          30m
kube-system   kube-scheduler-controlplane            1/1     Running   0          31m
controlplane $ kubectl get deployment --all-namespaces
NAMESPACE     NAME      READY   UP-TO-DATE   AVAILABLE   AGE
kube-system   coredns   2/2     2            2           31m
controlplane $ kubectl get services --all-namespaces
NAMESPACE     NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
default       kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP                  96s
kube-system   kube-dns     ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   31m
```  
    

### Luckily we took a backup. Restore the original state of the cluster using the backup file.

- Deployments: 2
- Services: 3

```bash
controlplane $ ETCDCTL_API=3 etcdctl help | grep restore
        snapshot restore        Restores an etcd member snapshot to an etcd directory

ETCDCTL_API=3 etcdctl  --data-dir /var/lib/etcd-from-backup \
     snapshot restore /opt/snapshot-pre-boot.db

controlplane $ ls /var/lib/etcd-from-backup
member

controlplane $ cd /etc/kubernetes/manifests/
controlplane $ ls
etcd.yaml  kube-apiserver.yaml  kube-controller-manager.yaml  kube-scheduler.yaml

## make following changes
controlplane $ cat etcd.yaml | grep -i from-backup -A 1 -B 1
  - hostPath:
      path: /var/lib/etcd-from-backup
      type: DirectoryOrCreate

## check the process restarted as its static pod
controlplane $ docker ps | grep -i etcd
1160b22e5eee        d4ca8726196c                     "etcd --advertise-cl…"   About a minute ago   Up About a minute                       k8s_etcd_etcd-controlplane_kube-system_3c7d14374da0d8247e20e917856facae_0
5b05b3e493b7        k8s.gcr.io/pause:3.2             "/pause"                 About a minute ago   Up About a minute 

## now the applications are backup 
controlplane $ kubectl get pods
NAME                    READY   STATUS    RESTARTS   AGE
blue-746c87566d-92l8p   1/1     Running   0          32m
blue-746c87566d-mnd6s   1/1     Running   0          32m
blue-746c87566d-n59pl   1/1     Running   0          32m
red-75f847bf79-g7258    1/1     Running   0          32m
red-75f847bf79-vch5j    1/1     Running   0          32m                      k8s_POD_etcd-controlplane_kube-system_3c7d14374da0d8247e20e917856facae_0
```