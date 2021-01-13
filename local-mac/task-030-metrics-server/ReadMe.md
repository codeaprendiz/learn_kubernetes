## Metrics-Server
Metrics server is an in-memory monitoring solution

The kubelet (agent which run on each node in kubernetes-cluster) also contains a component called cAdvisor (or container advisor).  It is resonsible for retrieving 
performance metrics from pods and exposing them through the kubelet api to make the mertics available for the metrics-server


### Deployment

[metrics-server](https://github.com/kubernetes-sigs/metrics-server)

Download the deployment files from here and deploy using

```bash
kubectl apply -f .
```


- Once deployed you can view the cluster performance by running following command.
  This gives CPU and Memory consumption of each of the nodes. 

```bash
$ kubectl top node
NAME           CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
controlplane   146m         7%     1048Mi          55%
node01         1998m        99%    585Mi           15%
```

- To view the performance metrics of pods. This gives CPU and Memory consumption of each of the pods.
```bash
$ kubectl top pods
NAME       CPU(cores)   MEMORY(bytes)
elephant   12m          50Mi
lion       899m         1Mi
rabbit     972m         1Mi
```