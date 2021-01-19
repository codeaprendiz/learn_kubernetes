
#### How many labels exist on node01
```bash
$ kubectl describe node node01 | grep -A 5  -i label
Labels:             beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/os=linux
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=node01
                    kubernetes.io/os=linux
Annotations:        flannel.alpha.coreos.com/backend-data: null

$ kubectl get nodes --show-labels | grep node01
node01         Ready    <none>   6m53s   v1.19.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=node01,kubernetes.io/os=linux
```

#### Apply a label color=blue to node node01
```bash
$ kubectl label node node01 color=blue
node/node01 labeled
```


#### Create a new deployment named blue with the nginx image and 6 replicas
```bash
$ kubectl create deployment --image=nginx blue
deployment.apps/blue created
$ kubectl scale deployment blue --replicas=6
deployment.apps/blue scaled
```

#### Which nodes can the pods for the blue deployment placed on?
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


#### Set Node Affinity to the deployment to place the pods on node01 only

- Name: blue
- Replicas: 6
- Image: nginx
- NodeAffinity: requiredDuringSchedulingIgnoredDuringExecution
- Key: color
- values: blue

- Create the deployment file 

```bash
$ kubectl get deployment blue -o yaml > blue.yaml
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

- Apply the changes 
```bash
$ kubectl apply -f blue.yaml
deployment.apps/blue configure
```

- What we changed
```bash
$ cat blue.yaml | grep -A 10 spec:
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
      containers:
```

- Now check the node affinity of the blue deployment pods

```bash
$ kubectl get pods -o wide
NAME                    READY   STATUS    RESTARTS   AGE   IP            NODE     NOMINATED NODE   READINESS GATES
blue-566c768bd6-77zfz   1/1     Running   0          76s   10.244.1.7    node01   <none>           <none>
blue-566c768bd6-9rrqn   1/1     Running   0          71s   10.244.1.11   node01   <none>           <none>
blue-566c768bd6-mtndx   1/1     Running   0          76s   10.244.1.9    node01   <none>           <none>
blue-566c768bd6-nqb9n   1/1     Running   0          76s   10.244.1.8    node01   <none>           <none>
blue-566c768bd6-tllbv   1/1     Running   0          73s   10.244.1.10   node01   <none>           <none>
blue-566c768bd6-wmgnh   1/1     Running   0          71s   10.244.1.12   node01   <none>           <none>
```


#### Create a new deployment named red with the nginx image and 3 replicas, and ensure it gets placed on the master/controlplane node only.

- Name: red
- Replicas: 3
- Image: nginx
- NodeAffinity: requiredDuringSchedulingIgnoredDuringExecution
- Key: node-role.kubernetes.io/master
- Use the Exists operator

- Create the deployment
```bash
$ kubectl create deployment red --image=nginx
deployment.apps/red created
```

- Scale the deployment
```bash
$ kubectl scale deployment red --replicas=3
deployment.apps/red scaled
```

- Get deployment 
```bash
$ kubectl get deployment red -o yaml > red.yaml
```

- Apply a label color=red to node controlplane
```bash
$ kubectl label node controlplane color=red
node/controlplane labeled
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
                - red
```

- Now check the red pods
```bash
$ kubectl get pods -o wide | grep red
red-6869b66f86-8n8nk    1/1     Running   0          6m2s    10.244.0.7    controlplane   <none>           <none>
red-6869b66f86-8p9gj    1/1     Running   0          5m59s   10.244.0.8    controlplane   <none>           <none>
red-6869b66f86-zs2qq    1/1     Running   0          6m5s    10.244.0.6    controlplane   <none>           <none>
```

- We could have achieved the same thing using the following key-value pair as well
    - Key: node-role.kubernetes.io/master
    - Use the Exists operator

- So add the following to yaml file
```yaml
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
                - red
              - key: node-role.kubernetes.io/master
                operator: Exists
```

- Now try applying the changes again. You will get the following error
```bash
for: "red.yaml": Operation cannot be fulfilled on deployments.apps "red": the object has been modified; please apply your changes to the latest version and try again
```

- This is because we didn't create the yaml file again from the latest version of object

```bash
$ kubectl get deployment red -o yaml > red.yaml
```

- Now adding the following to yaml part to `red.yaml`
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
                - red
              - key: node-role.kubernetes.io/master
                operator: Exists
```

- And applying the changes
```bash
$ kubectl apply -f red.yamldeployment.apps/red configured
```