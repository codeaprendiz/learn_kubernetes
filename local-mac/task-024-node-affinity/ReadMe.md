
- How many labels exist on node01
```bash
$ kubectl describe node node01 | grep -A 5  -i label
Labels:             beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/os=linux
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=node01
                    kubernetes.io/os=linux
Annotations:        flannel.alpha.coreos.com/backend-data: null
```

- Apply a label color=blue to node node01
```bash
$ kubectl label node node01 color=blue
node/node01 labeled
```


- Create a new deployment named blue with the nginx image and 6 replicas
```bash
$ kubectl create deployment --image=nginx blue
deployment.apps/blue created
$ kubectl scale deployment blue --replicas=6
deployment.apps/blue scaled
```

- Which nodes can the pods for the blue deployment placed on?
```bash
$ kubectl get pods --show-labels | grep "app=blue"
blue-7bb46df96d-56t7b   1/1     Running   0          4m8s    app=blue,pod-template-hash=7bb46df96d
blue-7bb46df96d-cjjdm   1/1     Running   0          4m14s   app=blue,pod-template-hash=7bb46df96d
blue-7bb46df96d-f78p2   1/1     Running   0          4m7s    app=blue,pod-template-hash=7bb46df96d
blue-7bb46df96d-fwzv8   1/1     Running   0          4m8s    app=blue,pod-template-hash=7bb46df96d
blue-7bb46df96d-g8dcv   1/1     Running   0          4m8s    app=blue,pod-template-hash=7bb46df96d
blue-7bb46df96d-qf5sq   1/1     Running   0          4m8s    app=blue,pod-template-hash=7bb46df96d

$ kubectl get nodes --show-labels | grep "app=blue" | wc -l
0

$ kubectl get pods -o wide
NAME                    READY   STATUS    RESTARTS   AGE     IP           NODE           NOMINATED NODE   READINESS GATES
blue-7bb46df96d-56t7b   1/1     Running   0          5m44s   10.244.0.6   controlplane   <none>           <none>
blue-7bb46df96d-cjjdm   1/1     Running   0          5m50s   10.244.1.3   node01         <none>           <none>
blue-7bb46df96d-f78p2   1/1     Running   0          5m43s   10.244.1.6   node01         <none>           <none>
blue-7bb46df96d-fwzv8   1/1     Running   0          5m44s   10.244.1.4   node01         <none>           <none>
blue-7bb46df96d-g8dcv   1/1     Running   0          5m44s   10.244.1.5   node01         <none>           <none>
blue-7bb46df96d-qf5sq   1/1     Running   0          5m44s   10.244.0.7   controlplane   <none>           <none>
```

##### IN PROGRESS TO BE VERIFIED
- Set Node Affinity to the deployment to place the pods on node01 only
```bash
Name: blue
Replicas: 6
Image: nginx
NodeAffinity: requiredDuringSchedulingIgnoredDuringExecution
Key: color
values: blue
```


```bash
$ kubectl get deployment blue -o yaml > blue-dep.yaml
```
- Now add the following to the deployment file
```yaml
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: color
                operator: In
                values:
                - blue
```

```bash
$ cat blue-dep.yaml | grep -A 10 spec:
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: color
                operator: In
                values:
                - blue
```