### We have deployed Ingress Controller, resources and applications. Explore the setup.

```bash
kubectl get all --all-namespaces
```

### Which namespace is the Ingress Controller deployed in?

```bash
ingress-space   pod/nginx-ingress-controller-697cfbd4d9-ktr55   1/1     Running   0          2m35s
```

### What is the name of the Ingress Controller Deployment?

```bash
ingress-space   deployment.apps/nginx-ingress-controller   1/1     1            1           2m36s
```

### Which namespace are the applications deployed in?

```bash
controlplane $ kubectl get all --all-namespaces
NAMESPACE       NAME                                            READY   STATUS    RESTARTS   AGE
app-space       pod/default-backend-5cf9bfb9d-qrc4m             1/1     Running   0          2m36s
app-space       pod/webapp-video-84f8655bd8-sfq8p               1/1     Running   0          2m36s
app-space       pod/webapp-wear-6ff9445955-fjw6k                1/1     Running   0          2m36s
ingress-space   pod/nginx-ingress-controller-697cfbd4d9-ktr55   1/1     Running   0          2m35s
.
.
```

### How many applications are deployed in the app-space namespace?

Count the number of deployments in this namespace

```bash
NAMESPACE       NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
app-space       deployment.apps/default-backend            1/1     1            1           2m36s
app-space       deployment.apps/webapp-video               1/1     1            1           2m36s
app-space       deployment.apps/webapp-wear                1/1     1            1           2m36s
ingress-space   deployment.apps/nginx-ingress-controller   1/1     1            1           2m36s
```

### Which namespace is the Ingress Resource deployed in?

```bash
$ kubectl get ingress --all-namespaces
Warning: extensions/v1beta1 Ingress is deprecated in v1.14+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
NAMESPACE   NAME                 CLASS    HOSTS   ADDRESS   PORTS   AGE
app-space   ingress-wear-watch   <none>   *                 80      8m11s
```

### What is the name of the Ingress Resource?

```bash
### ingress-wear-watch
```

### What is the Host configured on the ingress-resource?

The host entry defines the domain name that users use to reach the application like www.google.com

```bash
controlplane $ kubectl describe ingress ingress-wear-watch -n app-space
Warning: extensions/v1beta1 Ingress is deprecated in v1.14+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
Name:             ingress-wear-watch
Namespace:        app-space
Address:          
Default backend:  default-http-backend:80 (<error: endpoints "default-http-backend" not found>)
Rules:
  Host        Path  Backends
  ----        ----  --------
  *           
              /wear    wear-service:8080    10.244.2.2:8080)
              /watch   video-service:8080   10.244.2.3:8080)
Annotations:  nginx.ingress.kubernetes.io/rewrite-target: /
              nginx.ingress.kubernetes.io/ssl-redirect: false
Events:
  Type    Reason  Age    From                      Message
  ----    ------  ----   ----                      -------
  Normal  CREATE  9m21s  nginx-ingress-controller  Ingress app-space/ingress-wear-watch
  Normal  UPDATE  9m21s  nginx-ingress-controller  Ingress app-space/ingress-wear-watch
```

### What backend is the /wear path on the Ingress configured with?

```bash
##               /wear    wear-service:8080    10.244.2.2:8080)
```

### At what path is the video streaming application made available on the Ingress?

```bash
/watch
```

### If the requirement does not match any of the configured paths what service are the requests forwarded to?

```bash
## Default backend:  default-http-backend:80 (<error: endpoints "default-http-backend" not found>)
```

### You are requested to change the URLs at which the applications are made available.

Make the video application available at /stream.

```bash
controlplane $ kubectl get ingress ingress-wear-watch -n app-space -o yaml > ingress.yaml
## change the URL to /stream from /watch
```

### You are requested to add a new path to your ingress to make the food delivery application available to your customers.

Make the new application available at /eat.

```bash
controlplane $ kubectl get ingress ingress-wear-watch -n app-space -o yaml > ingress.yaml

controlplane $ kubectl apply -f ingress.yaml 
Warning: extensions/v1beta1 Ingress is deprecated in v1.14+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
ingress.extensions/ingress-wear-watch configured

controlplane $ cat ingress.yaml
.
.
  rules:
  - http:
      paths:
      - backend:
          serviceName: wear-service
          servicePort: 8080
        path: /wear
        pathType: ImplementationSpecific
      - backend:
          serviceName: video-service
          servicePort: 8080
        path: /stream
        pathType: ImplementationSpecific
      - backend:
          serviceName: food-service
          servicePort: 8080
        path: /eat
        pathType: ImplementationSpecific
```

### A new payment service has been introduced. Since it is critical, the new application is deployed in its own namespace.

Identify the namespace in which the new application is deployed

```bash
$ kubectl get svc --all-namespaces
NAMESPACE        NAME                   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
app-space        default-http-backend   ClusterIP   10.96.51.245     <none>        80/TCP                       35m
app-space        food-service           ClusterIP   10.108.245.102   <none>        8080/TCP                     9m49s
app-space        video-service          ClusterIP   10.105.246.205   <none>        8080/TCP                     35m
app-space        wear-service           ClusterIP   10.107.131.208   <none>        8080/TCP                     35m
critical-space   pay-service            ClusterIP   10.103.199.213   <none>        8282/TCP                     83s
default          kubernetes             ClusterIP   10.96.0.1        <none>        443/TCP                      36m
ingress-space    ingress-service        NodePort    10.104.120.24    <none>        80:30080/TCP,443:31008/TCP   35m
kube-system      kube-dns               ClusterIP   10.96.0.10       <none>        53/UDP,53/TCP,9153/TCP       36m
```

### What is the name of the deployment of the new application?

```bash
controlplane $ kubectl get deployment --all-namespaces
NAMESPACE        NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
app-space        default-backend            1/1     1            1           37m
app-space        webapp-food                1/1     1            1           11m
app-space        webapp-video               1/1     1            1           37m
app-space        webapp-wear                1/1     1            1           37m
critical-space   webapp-pay                 1/1     1            1           2m47s
```

### You are requested to make the new application available at /pay.

Identify and implement the best approach to making this application available on the ingress controller and test to make sure its working. Look into annotations: rewrite-target as well.

```bash
controlplane $ cat /var/answers/ingress-pay.yaml 
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: test-ingress
  namespace: critical-space
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - http:
      paths:
      - path: /pay
        backend:
          serviceName: pay-service
          servicePort: 8282
```


### Let us now deploy an Ingress Controller. First, create a namespace called 'ingress-space'

```bash
$ kubectl create namespace ingress-space
namespace/ingress-space created
```


### The NGINX Ingress Controller requires a ConfigMap object. Create a ConfigMap object in the ingress-space.

Use the given spec on the right. No data needs to be configured in the ConfigMap.
Name: nginx-configuration

```bash
$ kubectl create configmap nginx-configuration --namespace ingress-space
configmap/nginx-configuration created
```

### The NGINX Ingress Controller requires a ServiceAccount. Create a ServiceAccount in the ingress-space.

Name: ingress-serviceaccount

```bash
$ kubectl create serviceaccount ingress-serviceaccount --namespace ingress-space
serviceaccount/ingress-serviceaccount created
```

### Let us now create a service to make Ingress available to external users.

```bash
controlplane $ cat /var/answers/ingress-service.yaml
---
apiVersion: v1
kind: Service
metadata:
  name: ingress
  namespace: ingress-space
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    nodePort: 30080
    name: http
  - port: 443
    targetPort: 443
    protocol: TCP
    name: https
  selector:
    name: nginx-ingress
```

### Create the ingress resource to make the applications available at /wear and /watch on the Ingress service.

Create the ingress in the app-space


```bash
controlplane $ cat /var/answers/ingress-resource.yaml
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-wear-watch
  namespace: app-space
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
  - http:
      paths:
      - path: /wear
        backend:
          serviceName: wear-service
          servicePort: 8080
      - path: /watch
        backend:
          serviceName: video-service
          servicePort: 8080
```