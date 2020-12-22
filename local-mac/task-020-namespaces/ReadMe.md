

- To get how many Namespaces exist on the system?
```bash
$ kubectl get namespace         
NAME              STATUS   AGE
default           Active   78d
kube-node-lease   Active   78d
kube-public       Active   78d
kube-system       Active   78d
```

- How many pods exist in kube-system namespace
```bash
$ kubectl get pods -n kube-system
NAME                                     READY   STATUS    RESTARTS   AGE
coredns-864fccfb95-gwtl4                 1/1     Running   14         78d
coredns-864fccfb95-qqlmg                 1/1     Running   14         78d
etcd-docker-desktop                      1/1     Running   14         78d
kube-apiserver-docker-desktop            1/1     Running   15         78d
kube-controller-manager-docker-desktop   1/1     Running   14         78d
kube-proxy-nsmlj                         1/1     Running   14         78d
kube-scheduler-docker-desktop            1/1     Running   19         78d
storage-provisioner                      1/1     Running   27         78d
vpnkit-controller                        1/1     Running   16         78d

```

- To create a Pod in name `redis` from image `redis` in namespace `kube-system`
```bash
kubectl -n <namespace> get <resource type> <resource Name> -o yaml.
```