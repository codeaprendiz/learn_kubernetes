## Contents

- [apply](#apply)
- [delete](#delete)
- [describe](#describe)
    - [pod](#pod)
- [get](#get)
    - [namespace](#namespace)
    - [pod](#pod)
- [logs](#logs)
    - [since](#since)


## apply
[apply](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#apply)

- To apply the yaml resources.yaml
```bash
$ kubectl apply -f resources.yaml
deployment.apps/www created
service/www created
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
### since
- To get the output of logs of a given resource like pods
```bash
KUBECONFIG=$HOME/kubernetes/kubeconfig kubectl logs --since=1h module-5c8986fb69-8jvwx -n backend
```


## Test
test

test

test

test

test

test

test

test

test

test

test

test

test

test

test

test

test

test

test

test

test

test

test






