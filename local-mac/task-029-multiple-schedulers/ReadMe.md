### What is the name of the POD that deploys the default kubernetes scheduler in this environment?
```bash
$ kubectl get pods -n kube-system | grep scheduler
kube-scheduler-controlplane            1/1     Running   0          6m49s
```

### What is the image used to deploy the kubernetes scheduler?

```bash
$ kubectl describe pod kube-scheduler-controlplane  -n kube-system | grep -i image
    Image:         k8s.gcr.io/kube-scheduler:v1.19.0
```

### Deploy an additional scheduler to the cluster following the given specification.
Namespace: kube-system

Name: my-scheduler

Status: Running

Custom Scheduler Name

[configure-multiple-schedulers](https://kubernetes.io/docs/tasks/extend-kubernetes/configure-multiple-schedulers/)

```bash
controlplane $ cd /etc/kubernetes/manifests/

controlplane $ ls
etcd.yaml  kube-apiserver.yaml  kube-controller-manager.yaml  kube-scheduler.yaml

controlplane $ cp -rfp kube-scheduler.yaml ~/my-scheduler.yaml

controlplane $ vi my-scheduler.yaml

## Set the leader elect to fase and set the scheduler name
controlplane $ cat my-scheduler.yaml | grep -A 8  -i command
  - command:
    - kube-scheduler
    - --authentication-kubeconfig=/etc/kubernetes/scheduler.conf
    - --authorization-kubeconfig=/etc/kubernetes/scheduler.conf
    - --bind-address=127.0.0.1
    - --kubeconfig=/etc/kubernetes/scheduler.conf
    - --leader-elect=false
    - --scheduler-name=my-scheduler
    - --port=0

$ kubectl apply -f my-scheduler.yaml
pod/my-scheduler created

controlplane $ kubectl get pods -n kube-system | grep my-scheduler
my-scheduler                           1/1     Running   0          2m1s
```

### A POD definition file is given. Use it to create a POD with the new custom scheduler.
Name: nginx

Uses custom scheduler

Status: Running

- pod.yaml
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: annotation-default-scheduler
  labels:
    name: multischeduler-example
spec:
  schedulerName: my-scheduler
  containers:
  - name: pod-with-default-annotation-container
    image: k8s.gcr.io/pause:2.0
```

- and then run
```bash
kubectl apply -f pod.yaml

## To test the scheduler
kubectl get events

## You an also describe the pod and validate
kubectl describe pod nginx | grep my-scheduler
```