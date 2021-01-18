
### Identify the number of containers running in the 'red' pod.

```bash
controlplane $ kubectl describe pod red | grep -i "image id"
    Image ID:      docker-pullable://busybox@sha256:c5439d7db88ab5423999530349d327b04279ad3161d7596d2126dfb5b02bfd1f
    Image ID:      docker-pullable://busybox@sha256:c5439d7db88ab5423999530349d327b04279ad3161d7596d2126dfb5b02bfd1f
    Image ID:      docker-pullable://busybox@sha256:c5439d7db88ab5423999530349d327b04279ad3161d7596d2126dfb5b02bfd1f
```


### Identify the name of the containers running in the 'blue' pod.
```bash
controlplane $ kubectl get pod blue -o yaml | grep -i name: | egrep -v "f:|default|node"
  name: blue
    name: teal
    name: navy
    name: navy
    name: teal
```

### Create a multi-container pod with 2 containers.
- Name: yellow
- Container 1 Name: lemon
- Container 1 Image: busybox
- Container 2 Name: gold
- Container 2 Image: redis

```bash
controlplane $ kubectl run yellow --image=busybox --dry-run=client -o yaml > pod.yaml
controlplane $ cat pod.yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: yellow
  name: yellow
spec:
  containers:
  - image: busybox
    name: lemon
    resources: {}
  - image: redis
    name: gold
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}

controlplane $ kubectl apply -f pod.yaml
pod/yellow created
```

### Edit the pod to add a sidecar container to send logs to ElasticSearch. Mount the log volume to the sidecar container..

- Name: app
- Container Name: sidecar
- Container Image: kodekloud/filebeat-configured
- Volume Mount: log-volume
- Mount Path: /var/log/event-simulator/
- Existing Container Name: app
- Existing Container Image: kodekloud/event-simulator

```bash
controlplane $ kubectl exec -it app -n elastic-stack "ls" "log/app.log"
log/app.log

controlplane $ kubectl get pod app -n elastic-stack -o yaml > pod.yaml

controlplane $ kubectl delete -f pod.yaml
pod "app" deleted

controlplane $ kubectl apply -f pod.yaml
pod/app created

controlplane $ cat pod.yaml | grep -i containers: -A 17
  containers:
  - image: kodekloud/event-simulator
    imagePullPolicy: Always
    name: app
    resources: {}
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
    volumeMounts:
    - mountPath: /log
      name: log-volume
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: default-token-fzdbx
      readOnly: true
  - image: kodekloud/filebeat-configured
    name: sidecar
    volumeMounts:
    - mountPath: /var/log/event-simulator/
      name: log-volume
```