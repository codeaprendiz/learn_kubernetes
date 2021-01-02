# kubectl

- [apply-----------------------------------------To apply the yaml resources.yaml](#apply)
- [config](#config)
    - [current-context---------------------------To display the current context](#current-context)
    - [view--------------------------------------To display merged kubeconfig settings or a specified kubeconfig file.](#view)
    - [set-credentials---------------------------To set a user 'dave' entry in kubeconfig](#set-credentials)
- [create----------------------------------------To create a namespace dev-ns](#create)
    - [--dry-run---------------------------------Generate Deployment YAML file (-o yaml). Don't create it(--dry-run) with 4 Replicas (--replicas=4)](#--dry-run)
    - [-f----------------------------------------Create a pod using the data in pod.json.](#-f)
    - [--image-----------------------------------Create a deployment using nginx image, Create a new ClusterIP service named my-cs](#--image)
    - [-o yaml-----------------------------------Generate Deployment YAML file (-o yaml). Don't create it(--dry-run)](#-o-yaml)
- [delete----------------------------------------To delete deployment with name 'www' from default namespace](#delete)
    - [-f----------------------------------------Delete a pod using the type and name specified in pod.json.](#-f)
    - [--force-----------------------------------To immediately remove resources from API and bypass graceful deletion.](#--force)
    - [--grace-period----------------------------To delete a pod with zero grace period, delete immediately](#--grace-period)
    - [--namespace-------------------------------To delete pod web-pack in namespace frontend](#--namespace)
- [describe](#describe)
    - [pod---------------------------------------To describe a pod with name 'traefik-nb8p2' in ingress namespace](#pod)
- [edit------------------------------------------To change the image of nginx deployment to 1.9.0](#edit)
- [exec------------------------------------------To list all the keys stored by kubernetes](#exec) 
- [expose----------------------------------------Create a Service named redis-service of type ClusterIP to expose pod redis on port 6379](#expose)
- [get](#get)
    - [namespace---------------------------------To get all the namespace resources](#namespace)
        - [--no-headers--------------------------To get all the pods in given namespace and do not give header columns](#--no-headers)
    - [pod---------------------------------------To get all the pod resources in namespace ingress](#pod)
        - [--all-namespaces----------------------To view all the pods from all namespaces](#--all-namespaces)
        - [-n------------------------------------To view the pods in kube-system namespace](#-n)
- [logs](#logs)
    - [since-------------------------------------To get the output of logs of a given resource like pod since last one hour](#since)
    - [-f----------------------------------------Begin streaming the logs of the ruby container in pod web-1](#-f)
- [replace---------------------------------------Replace a pod using the data in pod.json.](#replace)
- [run](#run)
    - [--dry-run---------------------------------To NOT create nginx pod, only generate yaml ](#--dry-run)
    - [--image-----------------------------------To create NGINX pod](#--image)
    - [-n----------------------------------------To create a pod with image redis and name redis in namespace kube-system](#-n)
    - [-o yaml-----------------------------------To create nginx pod and generate the yaml](#-o-yaml)
    - [-p----------------------------------------Create a new pod called custom-nginx using the nginx image and expose it on container port 8080](#-p)
- [scale-----------------------------------------To scale a deployment named httpd-frontend to 3 replicas](#scale)
- [set-------------------------------------------Set a deployment's nginx container image to nginx:1.9.1](#set)


```bash
$ kubectl get pods --selector app=App1
$ kubectl get pods --show-labels
$ kubectl get pods -l env=dev
$ kubectl get pod -l env=prod,bu=finance,tier=frontend
$ kubectl get pods --selector app=App1
$ kubectl taint nodes node1 app=blue:NoSchedule
$ kubectl describe node docker-desktop | grep Taints
$ kubectl describe nodes master | grep -i taints
Taints:      node-role.kubernetes.io/master:NoSchedule      # copy this and put a `-` at the end to remove it
$ kubectl taint nodes master node-role.kubernetes.io/master:NoSchedule-  
$ kubectl explain pod --recursive | less
$ kubectl label nodes <node-name> <label-key>=<label-value> 
$ kubectl label nodes node-1 size=Large
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

### -f
- Create a pod using the data in pod.json.
```bash
kubectl create -f ./pod.json
```

### --image
- Create a deployment using nginx image
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

### -f
- Delete a pod using the type and name specified in pod.json.
```bash
kubectl delete -f ./pod.json
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

## edit
[edit](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#edit)
- To change the image of nginx deployment to 1.9.0
```bash
$ kubectl create deployment my-dep --image=nginx
deployment.apps/my-dep created
$ kubectl describe deployment my-dep | grep -i image
    Image:        nginx
$ kubectl edit deployment my-dep                    
deployment.apps/my-dep edited
$ kubectl describe deployment my-dep | grep -i image
    Image:        nginx:1.9.0
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

#### --all-namespaces
- To view all the pods from all namespaces
```bash
$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                     READY   STATUS    RESTARTS   AGE
kube-system   coredns-864fccfb95-gwtl4                 1/1     Running   14         78d
kube-system   coredns-864fccfb95-qqlmg                 1/1     Running   14         78d
```

#### -n
- To view the pods in `kube-system` namespace
```bash
$ kubectl get pods -n kube-system        
NAME                                     READY   STATUS    RESTARTS   AGE
coredns-864fccfb95-gwtl4                 1/1     Running   14         78d
coredns-864fccfb95-qqlmg                 1/1     Running   14         78d
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

## replace
[replace](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#replace)
- Replace a pod using the data in pod.json.
```bash
kubectl replace -f ./pod.json
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


## set
[set](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#set)

- Set a deployment's nginx container image to `nginx:1.9.1`
```bash
$ kubectl create deployment my-dep --image=nginx
deployment.apps/my-dep created
$ kubectl describe deployment my-dep | grep -i image
    Image:        nginx
$ kubectl set image deployment my-dep nginx=nginx:1.9.1
deployment.apps/my-dep image updated
$ kubectl describe deployment my-dep | grep -i image  
    Image:        nginx:1.9.1
```
