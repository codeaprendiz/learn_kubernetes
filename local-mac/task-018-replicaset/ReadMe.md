
- How many replicasets exist
```bash
$ kubectl get replicaset        
No resources found in default namespace.
```

- Which image has been used to create pods using the 
  replica set
```bash
$ kubectl describe replicaset replicaset-1 | grep Image
    Image:        nginx
```

- How many pods are in ready state
```bash
$ kubectl get pods                                     
NAME                 READY   STATUS    RESTARTS   AGE
replicaset-1-66pmk   1/1     Running   0          60s
replicaset-1-tmlkq   1/1     Running   0          60s
```

- Create a replicaset using nginx image
```bash
kubectl apply -f replicaset.yaml
```

> NOTE: The selector:matchLabels:A:B and template:metadata:labels:A:B must always match. It makes sense as the replica set is aimed at maintaining pods which have lables mentioned (for example)  A:B


- Can you edit the existing the replicaset to have more pods
```bash
$ kubectl edit replicaset replicaset-1                                       
replicaset.apps/replicaset-1 edited

OR

$ kubectl scale replicaset --replicas=5 replicaset-1 
replicaset.apps/replicaset-1 scaled
```
