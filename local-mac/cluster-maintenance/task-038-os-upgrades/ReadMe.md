
### Let us explore the environment first. How many nodes do you see in the cluster?
```bash
controlplane $ kubectl get nodes
NAME           STATUS   ROLES    AGE     VERSION
controlplane   Ready    master   3m20s   v1.19.0
node01         Ready    <none>   2m50s   v1.19.0
node02         Ready    <none>   2m51s   v1.19.0
node03         Ready    <none>   2m51s   v1.19.0
```

### How many applications do you see hosted on the cluster?

- Check the number of deployments
  
```bash
controlplane $ kubectl get deployments
NAME   READY   UP-TO-DATE   AVAILABLE   AGE
blue   3/3     3            3           47s
red    2/2     2            2           47s
```

### On which nodes are the applications hosted on?

```bash
controlplane $ kubectl get pods -o wide
NAME                    READY   STATUS    RESTARTS   AGE    IP           NODE     NOMINATED NODE   READINESS GATES
blue-746c87566d-bnvsh   1/1     Running   0          105s   10.244.1.4   node03   <none>           <none>
blue-746c87566d-g7vlk   1/1     Running   0          105s   10.244.2.3   node02   <none>           <none>
blue-746c87566d-xj6b9   1/1     Running   0          105s   10.244.3.3   node01   <none>           <none>
red-75f847bf79-fcjbj    1/1     Running   0          105s   10.244.1.3   node03   <none>           <none>
red-75f847bf79-rv62t    1/1     Running   0          105s   10.244.2.2   node02   <none>           <none>
```

### We need to take node01 out for maintenance. Empty the node of all applications and mark it unschedulable.
- Node node01 Unschedulable
- Pods evicted from node01

```bash
controlplane $ kubectl drain node01 --ignore-daemonsets
node/node01 already cordoned
WARNING: ignoring DaemonSet-managed Pods: kube-system/kube-flannel-ds-amd64-j5gwb, kube-system/kube-proxy-29qlc
evicting pod default/blue-746c87566d-xj6b9
evicting pod kube-system/coredns-f9fd979d6-79bmc
pod/coredns-f9fd979d6-79bmc evicted
pod/blue-746c87566d-xj6b9 evicted
node/node01 evicted
```

### What nodes are the apps on now?

```bash
controlplane $ kubectl get pods -o wide
NAME                    READY   STATUS    RESTARTS   AGE     IP           NODE     NOMINATED NODE   READINESS GATES
blue-746c87566d-bnvsh   1/1     Running   0          24m     10.244.1.4   node03   <none>           <none>
blue-746c87566d-g7vlk   1/1     Running   0          24m     10.244.2.3   node02   <none>           <none>
blue-746c87566d-rw5bt   1/1     Running   0          2m33s   10.244.1.5   node03   <none>           <none>
red-75f847bf79-fcjbj    1/1     Running   0          24m     10.244.1.3   node03   <none>           <none>
red-75f847bf79-rv62t    1/1     Running   0          24m     10.244.2.2   node02   <none>           <none>
```

### The maintenance tasks have been completed. Configure the node to be schedulable again.

```bash
controlplane $ kubectl uncordon node01
node/node01 uncordoned
```

### How many pods are scheduled on node01 now?

```bash
controlplane $ kubectl get pods -o wide
NAME                    READY   STATUS    RESTARTS   AGE     IP           NODE     NOMINATED NODE   READINESS GATES
blue-746c87566d-bnvsh   1/1     Running   0          26m     10.244.1.4   node03   <none>           <none>
blue-746c87566d-g7vlk   1/1     Running   0          26m     10.244.2.3   node02   <none>           <none>
blue-746c87566d-rw5bt   1/1     Running   0          4m30s   10.244.1.5   node03   <none>           <none>
red-75f847bf79-fcjbj    1/1     Running   0          26m     10.244.1.3   node03   <none>           <none>
red-75f847bf79-rv62t    1/1     Running   0          26m     10.244.2.2   node02   <none>           <none>
```


### Why are there no pods on node01?

- Only when pods are created, they are scheduled.

### It is now time to take down node02 for maintenance. 

Before you remove all workload from node02 answer the following question.
Can you drain node02 using the same command as node01? Try it.

```bash
controlplane $ kubectl drain node02 --ignore-daemonsets
node/node02 already cordoned
error: unable to drain node "node02", aborting command...

There are pending nodes to be drained:
 node02
error: cannot delete Pods not managed by ReplicationController, ReplicaSet, Job, DaemonSet or StatefulSet (use --force to override): default/hr-app
```

### Why do you need to force the drain?

node02 has a pod that is `NOT` part of a replicaset i.e. `default/hr-app` in the above output.


### What would happen to hr-app if node02 is drained forcefully?

hr-app will be lost forever


### Drain node02 and mark it unschedulable
```bash
controlplane $ kubectl drain node02 --force --ignore-daemonsets
node/node02 already cordoned
WARNING: deleting Pods not managed by ReplicationController, ReplicaSet, Job, DaemonSet or StatefulSet: default/hr-app; ignoring DaemonSet-managed Pods: kube-system/kube-flannel-ds-amd64-ttxbv, kube-system/kube-proxy-nh7k5
evicting pod default/hr-app
evicting pod default/blue-746c87566d-g7vlk
evicting pod default/red-75f847bf79-rv62t
evicting pod kube-system/coredns-f9fd979d6-g64fp
pod/red-75f847bf79-rv62t evicted
pod/hr-app evicted
pod/blue-746c87566d-g7vlk evicted
pod/coredns-f9fd979d6-g64fp evicted
node/node02 evicted
```

### Node03 has our critical applications. We do not want to schedule any more apps on node03. Mark node03 as unschedulable but do not remove any apps currently running on it .

- Node03 Unschedulable
- Node03 has apps

```bash
controlplane $ kubectl cordon node03
node/node03 cordoned
```