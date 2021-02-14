### Identify the DNS solution implemented in this cluster.
    
```bash
controlplane $ kubectl get pods -n kube-system
NAME                                   READY   STATUS    RESTARTS   AGE
coredns-f9fd979d6-g7zpm                1/1     Running   0          3m16s
coredns-f9fd979d6-hm4lx                1/1     Running   0          3m16s
```

### How many pods of the DNS server are deployed?
    
```bash
## 2
```

### What is the name of the service created for accessing CoreDNS?
    
    
```bash
$ kubectl get svc -n kube-system
NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   5m56s
```

### What is the IP of the CoreDNS server that should be configured on PODs to resolve services?

```bash
## 10.96.0.10
```

### Where is the configuration file located for configuring the CoreDNS service?
    
    
```bash
kubectl -n kube-system describe deployments.apps coredns | grep -A2 Args | grep Corefile
      /etc/coredns/Corefile
```

### How is the Corefile passed in to the CoreDNS POD?
    
    
```bash
Configured as configmap object
```

### What is the name of the ConfigMap object created for Corefile?
    
    
```bash
$ kubectl get configmap -n kube-system
NAME                                 DATA   AGE
coredns                              1      18m
```

### What is the root domain/zone configured for this kubernetes cluster?
    
    
```bash
$ kubectl describe configmap coredns -n kube-system
Name:         coredns
Namespace:    kube-system
Labels:       <none>
Annotations:  <none>

Data
====
Corefile:
----
.:53 {
    errors
    health {
       lameduck 5s
    }
    ready
    kubernetes cluster.local in-addr.arpa ip6.arpa {
       pods insecure
       fallthrough in-addr.arpa ip6.arpa
       ttl 30
    }
    prometheus :9153
    forward . /etc/resolv.conf {
       max_concurrent 1000
    }
    cache 30
    loop
    reload
    loadbalance
}

Events:  <none>
```

### What name can be used to access the hr web server from the test Application?

- You can execute a curl command on the test pod to test. Alternatively, the test Application also has a UI. Access it using the tab at the top of your terminal named"test-app"

```bash
controlplane $ kubectl describe svc web-service
Name:              web-service
Namespace:         default
Labels:            <none>
Annotations:       <none>
Selector:          name=hr
Type:              ClusterIP
IP:                10.103.94.106
Port:              <unset>  80/TCP
TargetPort:        80/TCP
Endpoints:         10.244.1.5:80
Session Affinity:  None
Events:            <none>
```

### Which of the below name can be used to access the payroll service from the test application?

```bash
$ kubectl get svc --all-namespaces | grep payroll
payroll       web-service    ClusterIP   10.101.247.80    <none>        80/TCP                   23m

$ kubectl describe svc --all-namespaces
Name:              web-service
Namespace:         payroll
Labels:            <none>
Annotations:       <none>
Selector:          name=web
Type:              ClusterIP
IP:                10.101.247.80
Port:              <unset>  80/TCP
TargetPort:        80/TCP
Endpoints:         10.244.1.3:80
Session Affinity:  None
Events:            <none>

### webservice.payroll
```


### We just deployed a web server - webapp - that accesses a database mysql - server. However the web server is failing to connect to the database server. Troubleshoot and fix the issue.

- They could be in different namespaces. First locate the appliations. The web server interface can be seen by clicking the tab Web Server at the top of your terminal.

```bash
$ kubectl get pods --all-namespaces | egrep "mysql|webapp"
default       simple-webapp-1                        1/1     Running   0          29m
default       simple-webapp-122                      1/1     Running   0          29m
default       webapp-84ffb6ddff-s894b                1/1     Running   0          2m27s
payroll       mysql                                  1/1     Running   0          2m26s

## fix the by changing the hostname mysql to mysql.payroll
controlplane $ kubectl get deployment webapp -o yaml > dep.yaml
```

### From the hr pod nslookup the mysql service and redirect the output to a

```bash
kubectl exec -it hr -- nslookup mysql.payroll > /root/CKA/nslookup.out
```