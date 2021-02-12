
### Inspect the kubelet service and identify the network plugin configured for Kubernetes.

- Run ps -aux | grep kubelet command

```bash
controlplane $ ps -aux | grep kubelet
root      2148  6.3 19.0 1163472 388908 ?      Ssl  10:14   1:03 kube-apiserver --advertise-address=172.17.0.29 --allow-privileged=true --authorization-mode=Node,RBAC --client-ca-file=/etc/kubernetes/pki/ca.crt --enable-admission-plugins=NodeRestriction --enable-bootstrap-token-auth=true --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key --etcd-servers=https://127.0.0.1:2379 --insecure-port=0 --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client.key --requestheader-allowed-names=front-proxy-client --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt --requestheader-extra-headers-prefix=X-Remote-Extra- --requestheader-group-headers=X-Remote-Group --requestheader-username-headers=X-Remote-User --secure-port=6443 --service-account-key-file=/etc/kubernetes/pki/sa.pub --service-cluster-ip-range=10.96.0.0/12 --tls-cert-file=/etc/kubernetes/pki/apiserver.crt --tls-private-key-file=/etc/kubernetes/pki/apiserver.key
root      6398  3.6  4.7 1856936 97604 ?       Ssl  10:21   0:22 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml --cgroup-driver=systemd --network-plugin=cni --pod-infra-container-image=k8s.gcr.io/pause:3.1 --cni-bin-dir=/opt/cni/bin
root     12121  0.0  0.0  14736  1016 pts/0    S+   10:31   0:00 grep --color=auto kubelet
```


### What is the path configured with all binaries of CNI supported plugins?


```bash
### --cni-bin-dir=/opt/cni/bin
```

### Identify which of the below plugins is not available in the list of available CNI plugins on this host

```bash
$ ls /opt/cni/bin
bandwidth  dhcp      host-device  ipvlan    macvlan  ptp  static  vlan        weave-net
bridge     firewall  host-local   loopback  portmap  sbr  tuning  weave-ipam  weave-plugin-2.8.1
```


### What is the CNI plugin configured to be used on this kubernetes cluster?

```bash
$ ls /etc/cni/net.d/ 
10-weave.conflist

controlplane $ cat /etc/cni/net.d/10-weave.conflist
{
    "cniVersion": "0.3.0",
    "name": "weave",
    "plugins": [
        {
            "name": "weave",
            "type": "weave-net",
            "hairpinMode": true
        },
        {
            "type": "portmap",
            "capabilities": {"portMappings": true},
            "snat": true
        }
    ]
}
```


### What binary executable file will be run by kubelet after a container and its associated namespace are created.

```bash
###             "type": "weave-net",
```