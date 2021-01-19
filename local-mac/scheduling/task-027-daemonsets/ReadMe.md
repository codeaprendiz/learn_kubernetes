
### How many DaemonSets are created in the cluster in all namespaces?
    
```bash
$ kubectl get daemonset --all-namespaces
NAMESPACE     NAME                      DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
kube-system   kube-flannel-ds-amd64     2         2         2       2            2           <none>                   14m
kube-system   kube-flannel-ds-arm       0         0         0       0            0           <none>                   14m
kube-system   kube-flannel-ds-arm64     0         0         0       0            0           <none>                   14m
kube-system   kube-flannel-ds-ppc64le   0         0         0       0            0           <none>                   14m
kube-system   kube-flannel-ds-s390x     0         0         0       0            0           <none>                   14m
kube-system   kube-proxy                2         2         2       2            2           kubernetes.io/os=linux   14m
```


### On how many nodes are the pods scheduled by the DaemonSet kube-proxy
    
```bash
$ kubectl get nodes --no-headers=true| wc -l
2
```

### What is the image used by the POD deployed by the kube-flannel-ds-amd64 DaemonSet?
    
```bash
$ kubectl describe pod kube-flannel-ds-amd64 -n kube-system | grep -i "pulling image"
  Normal  Pulling    20m   kubelet, controlplane  Pulling image "quay.io/coreos/flannel:v0.12.0-amd64"
```

### Deploy a DaemonSet for FluentD Logging

- Name: elasticsearch
- Namespace: kube-system
- Image: k8s.gcr.io/fluentd-elasticsearch:1.20

Go the official [doc](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)

Copy and make corresponding changes

daemonset.yaml
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: elasticsearch
  namespace: kube-system
  labels:
    k8s-app: fluentd-logging
spec:
  selector:
    matchLabels:
      name: fluentd-elasticsearch
  template:
    metadata:
      labels:
        name: fluentd-elasticsearch
    spec:
      tolerations:
      # this toleration is to have the daemonset runnable on master nodes
      # remove it if your masters can't run pods
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
      containers:
      - name: fluentd-elasticsearch
        image: k8s.gcr.io/fluentd-elasticsearch:1.20
        resources:
          limits:
            memory: 200Mi
          requests:
            cpu: 100m
            memory: 200Mi
        volumeMounts:
        - name: varlog
          mountPath: /var/log
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
      terminationGracePeriodSeconds: 30
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
```

and then run the `kubectl apply -f .` command