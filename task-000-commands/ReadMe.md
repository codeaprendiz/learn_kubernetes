# kubectl

- [apply](#apply)
- [config](#config)
    - [current-context](#current-context)
    - [view](#view)
    - [set-credentials](#set-credentials)
- [create](#create)
    - [--dry-run](#--dry-run)
    - [--image](#--image)
    - [-o yaml](#-o-yaml)
- [delete](#delete)
    - [--force](#--force)
    - [--grace-period](#--grace-period)
    - [--namespace](#--namespace)
- [describe](#describe)
    - [pod](#pod)
- [exec](#exec) 
- [expose](#expose)
- [get](#get)
    - [namespace](#namespace)
        - [--no-headers](#--no-headers)
    - [pod](#pod)
        - [-n](#-n)
        - [--all-namespaces](#--all-namespaces)
- [logs](#logs)
    - [since](#since)
    - [-f](#-f)
- [run](#run)
    - [--dry-run](#--dry-run)
    - [--image](#--image)
    - [-n](#-n)
    - [-o yaml](#-o-yaml)
    - [-p](#-p)
- [scale](#scale)


```bash
$ kubectl set image deployment nginx nginx=nginx:1.18
$ kubectl edit deployment nginx
$ kubectl create -f nginx.yaml
$ kubectl replace -f nginx.yaml
$ kubectl delete -f nginx.yaml
$ kubectl get pods --selector app=App1
$ kubectl get pods --show-labels
$ kubectl get pods -l env=dev
$ kubectl get pod -l env=prod,bu=finance,tier=frontend
$ kubectl get pods --selector app=App1
$ kubectl taint nodes node1 app=blue:NoSchedule
$ kubectl describe node docker-desktop | grep Taints
```



## apply
[apply](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply)

- To apply the yaml resources.yaml
```bash
$ kubectl apply -f resources.yaml
deployment.apps/www created
service/www created
```

## config
[config](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#config)

### current-context

- To display the current context
```bash
$ kubectl config current-context                                                  
docker-desktop
```


### view
- To display merged kubeconfig settings or a specified kubeconfig file.
```bash
$ kubectl config view --raw -o json | jq -r '.clusters[].cluster."server"'
https://kubernetes.docker.internal:6443
```


### set-credentials
- To set a user 'dave' entry in kubeconfig

```bash
kubectl config set-credentials dave --client-key=$PWD/dave.key --embed-certs=true
```

## create
[create](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#create)

- To create a namespace dev-ns
```bash
kubectl create namespace dev-ns
```

### --dry-run
- Generate Deployment YAML file (-o yaml). Don't create it(--dry-run) with 4 Replicas (--replicas=4)
```bash
kubectl create deployment --image=nginx nginx --dry-run=client --replicas=4 -o yaml > nginx-deployment.yaml
```

### --image
- Create a deployment
```bash
kubectl create deployment --image=nginx nginx
```
- Create a new ClusterIP service named my-cs
```bash
kubectl create service clusterip my-cs --tcp=5678:8080
```

- Create a Service named nginx of type NodePort to expose pod nginx's port 80 on port 30080 on the nodes. 
  This will automatically use the pod's labels as selectors, but you cannot specify the node port. You have to generate a definition file and then add the node port in manually before creating the service with the pod
```bash
kubectl create service nodeport nginx --tcp=80:80 --node-port=30080 --dry-run=client -o yaml
```
### -o yaml 
- Generate Deployment YAML file (-o yaml). Don't create it(--dry-run)
```bash
kubectl create deployment --image=nginx nginx --dry-run=client -o yaml
```



## delete
[delete](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#delete)

- To delete deployment with name 'www' from default namespace
```bash
$ kubectl delete deployment www
deployment.extensions "www" deleted
```
### --force
- To immediately remove resources from API and bypass graceful deletion.
```bash
kubectl delete pod <PODNAME> --grace-period=0 --force --namespace <NAMESPACE>
```

### --grace-period
- To delete a pod with zero grace period, delete immediately. It is the period of time in seconds given to the resource to terminate gracefully.
```bash
kubectl delete pod <PODNAME> --grace-period=0 --force --namespace <NAMESPACE>
```

### --namespace
- To delete pod web-pack in namespace frontend
```bash
kubectl delete pod web-pack --namespace frontend
```

## describe
[describe](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#describe)
### pod 

- To describe a pod with name 'traefik-nb8p2' in ingress namespace
```bash
$ kubectl describe pod traefik-nb8p2 -n ingress
Name:           traefik-nb8p2
Namespace:      ingress
.
.
.
Events:          <none>
```

## exec
[exec](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#exec)
- To list all the keys stored by kubernetes
```bash
kubectl exec etcd-master -n kube-system etcdctl get / --prefix -keys-only
```

## expose
[expose](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#expose)

- Create a Service named redis-service of type ClusterIP to expose pod redis on port 6379. Note dry run won't actually create it. 
  We will get the yaml file using the following command.
```bash
kubectl expose pod redis --port=6379 --name redis-service --dry-run=client -o yaml
```

- Create a service for an nginx deployment, which serves on port 80 and connects to the containers on port 8000.
```bash
kubectl expose deployment nginx --port=80 --target-port=8000
```

- Create a Service named nginx of type NodePort to expose pod nginx's port 80 on port 30080 on the nodes. 
  This will automatically use the pod's labels as selectors, but you cannot specify the node port. 
  You have to generate a definition file and then add the node port in manually before creating the service with the pod
```bash
kubectl expose pod nginx --port=80 --name nginx-service --type=NodePort --dry-run=client -o yaml
```

## get
[get](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get)
### namespace
- To get all the namespace resources
```bash
$ kubectl get namespace
NAME                   STATUS   AGE
default                Active   9d
```

#### --no-headers

- To get all the pods in given namespace and do not give header columns
```bash
$ kubectl get pods -n kube-system --no-headers
coredns-864fccfb95-gwtl4                 1/1   Running   14    78d
coredns-864fccfb95-qqlmg                 1/1   Running   14    78d
```

### pod
- To get all the pod resources in namespace ingress
```bash
$ kubectl get pod -n ingress
NAME            READY   STATUS    RESTARTS   AGE
traefik-nb8p2   1/1     Running   13         9d
```
- To output all the pods in namespace ingress in yaml format
```bash
$ kubectl get pod -n ingress -o yaml
apiVersion: v1
items:
- apiVersion: v1
  kind: Pod
.
.
.
  selfLink: ""
```
- To output single pod with name 'traefik-nb8p2' in namespace ingress in yaml format
```bash
$ kubectl get pod traefik-nb8p2 -n ingress -o yaml
```

#### -n
- To view the pods in `kube-system` namespace
```bash
$ kubectl get pods -n kube-system        
NAME                                     READY   STATUS    RESTARTS   AGE
coredns-864fccfb95-gwtl4                 1/1     Running   14         78d
coredns-864fccfb95-qqlmg                 1/1     Running   14         78d
```

#### --all-namespaces
```bash
$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                     READY   STATUS    RESTARTS   AGE
kube-system   coredns-864fccfb95-gwtl4                 1/1     Running   14         78d
kube-system   coredns-864fccfb95-qqlmg                 1/1     Running   14         78d
```

## logs
[logs](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#logs)
### since
- To get the output of logs of a given resource like 'pod' since last one hour
```bash
KUBECONFIG=$HOME/kubernetes/kubeconfig kubectl logs --since=1h module-5c8986fb69-8jvwx -n backend
```

### -f
- Begin streaming the logs of the ruby container in pod web-1
```bash
kubectl logs -f -c ruby web-1
```

- Begin streaming the logs from all containers in pods defined by label app=nginx
```bash
kubectl logs -f -lapp=nginx --all-containers=true
```



## run
[run](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#run)

### --dry-run
- To NOT create nginx pod, only generate yaml 
```bash
kubectl run nginx --image=nginx --dry-run=client -o yaml
```

### --image

- To create NGINX pod
```bash
kubectl run nginx --image=nginx
```

### -n
- To create a pod with image `redis` and name `redis` in namespace `kube-system`
```bash
$ kubectl run redis --image=redis --dry-run=client -n kube-system -o yaml > pod.yaml
$ kubectl apply -f .
OR
$ kubectl run redis --image=redis -n kube-system
```

### -o yaml 
- To create nginx pod and generate the yaml
```bash
kubectl run nginx --image=nginx -o yaml
```

### -p 
- Create a new pod called custom-nginx using the nginx image and expose it on container port 8080
```bash
kubectl run custom-nginx --image=nginx --port=5701
```

## scale
[scale](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#scale)

- To scale a deployment named `httpd-frontend` to 3 replicas
```bash
$ kubectl scale deployment httpd-frontend --replicas=3
```


