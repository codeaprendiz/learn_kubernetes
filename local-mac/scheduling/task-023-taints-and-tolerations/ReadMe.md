
- Do any taints exist on any of the nodes?
```bash
$ kubectl describe node | egrep  "Taints|Name:"
Name:               controlplane
Taints:             node-role.kubernetes.io/master:NoSchedule
Name:               node01
Taints:             <none>
```


- Create a taint on node01 with key of 'spray', value of 'mortein' and effect of 'NoSchedule'
```bash
$ kubectl taint nodes node01 spray=mortein:NoSchedule
node/node01 tainted
```

- Suppose we have a pod created using following yaml
```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: mosquito
spec:
  containers:
  - image: nginx
    name: nginx
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}
```
and `kubectl apply -f .` we get the following error
```bash
FailedScheduling  62s (x3 over 2m10s)  default-scheduler  0/2 nodes are available: 1 node(s) had taint {node-role.kubernetes.io/master: }, thatthe pod didn't tolerate, 1 node(s) had taint {spray: mortein}, that the pod didn't tolerate.
```

How can we fix it?
```bash
$ cat pod1.yaml | grep -A 4 -B 1 tolerations:
  restartPolicy: Always
  tolerations:
  - key: "spray"
    operator: "Equal"
    value: "mortein"
    effect: "NoSchedule"
```

- Remove the taint on master, which currently has the taint effect of NoSchedule
```bash
$ kubectl describe nodes master | grep -i taints
Taints:      node-role.kubernetes.io/master:NoSchedule      # copy this and put a `-` at the end to remove it
$ kubectl taint nodes master node-role.kubernetes.io/master:NoSchedule-
node/master untainted
```