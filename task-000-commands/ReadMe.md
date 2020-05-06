# kubectl

- [apply](#apply)
- [config](#config)
    - [view](#view)
    - [set-credentials](#set-credentials)
- [delete](#delete)
- [describe](#describe)
    - [pod](#pod)
- [get](#get)
    - [namespace](#namespace)
    - [pod](#pod)
- [logs](#logs)
    - [since](#since)
    - [-f](#-f)

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

## delete
[delete](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#delete)

- To delete deployment with name 'www' from default namespace
```bash
$ kubectl delete deployment www
deployment.extensions "www" deleted
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

## get
[get](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#get)
### namespace
- To get all the namespace resources
```bash
$ kubectl get namespace
NAME                   STATUS   AGE
default                Active   9d
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

## Test


Force deleting
https://stackoverflow.com/questions/35453792/pods-stuck-in-terminating-status





