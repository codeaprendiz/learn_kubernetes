
- To get the number of pods 
```
$ kubectl get pods
No resources found in default namespace.
```

- To create pod with `nginx` imgae
```bash
$ kubectl run nginx --image=nginx
pod/nginx created
```

- To check what image is used to create the pod
```bash
$ kubectl describe pod nginx | grep -i image
    Image:          nginx
```

- Which nodes are these pods based on 
```bash
$ kubectl get pods -o wide                  
NAME    READY   STATUS    RESTARTS   AGE     IP           NODE             NOMINATED NODE   READINESS GATES
nginx   1/1     Running   0          2m27s   10.1.4.225   docker-desktop   <none>           <none>
```

- How many containers are running 
> 1/1        Running containers/Total Containers

- What is the state of the container running
```bash
$ kubectl describe pod nginx | grep -i state
    State:          Running
```

- Can you get the event section output of the pod
```bash
$ kubectl describe pod nginx | tail -n 8 
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  5m37s  default-scheduler  Successfully assigned default/nginx to docker-desktop
  Normal  Pulling    5m36s  kubelet            Pulling image "nginx"
  Normal  Pulled     5m21s  kubelet            Successfully pulled image "nginx"
  Normal  Created    5m21s  kubelet            Created container nginx
  Normal  Started    5m21s  kubelet            Started container nginx
```

- Can you delete the pod `nginx`
```bash
$ kubectl delete pod nginx              
pod "nginx" deleted
```

- Create a redis pod using `redis` image by using command line, also generate the corresponding yaml file. Do a dry run first to create
  the yaml and then use the yaml to create the pod.
```bash
$ kubectl run redis --image=redis --dry-run=client -o yaml > redis.yml
$ kubectl create -f redis.yml 
pod/redis created
```