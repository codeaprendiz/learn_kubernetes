
#### A pod named 'rabbit' is deployed. Identify the CPU requirements set on the Pod

```bash
$ kubectl get pod rabbit -o yaml | grep -A 4 resource
    resources:
      limits:
        cpu: "2"
      requests:
        cpu: "1"
```

> The status 'OOMKilled' indicates that the pod ran out of memory. Identify the memory limit set on the POD.

#### The elephant runs a process that consume 15Mi of memory. Increase the limit of the elephant pod to 20Mi.

- Generate the yaml
````bash
$ kubectl get pod elephant -o yaml > pod.yaml
````

- Edit the file
```bash
$ cat pod.yaml | grep -A 4 resources
    resources:
      limits:
        memory: 20Mi
      requests:
        memory: 5Mi
```

- Delete the pod
```bash
$ kubectl delete pod elephant
pod "elephant" deleted
```

- Create the pod again
```bash
$ kubectl apply -f pod.yaml
pod/elephant created
```