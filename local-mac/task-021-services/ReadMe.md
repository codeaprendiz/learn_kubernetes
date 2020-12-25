

- To get the number of services
```bash
$ kubectl get services                                
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   80d
```

- Try getting the details like Target Port and Labels
```bash
$ kubectl describe service kubernetes                                          
Name:              kubernetes
Namespace:         default
Labels:            component=apiserver
                   provider=kubernetes
Annotations:       <none>
Selector:          <none>
Type:              ClusterIP
IP:                10.96.0.1
Port:              https  443/TCP
TargetPort:        6443/TCP
Endpoints:         192.168.65.3:6443
Session Affinity:  None
Events:            <none>
```

- Create nginx deployment. Then create a service of name: webapp-service, type: NodePort, targetPort: 80, nodePort:30008, port:8080, selector: simple-app to access the nginx deployment
```yaml
$ kubectl create deployment my-dep --image=nginx
deployment.apps/my-dep created

$ kubectl expose deployment my-dep --name=webapp-service --target-port=80 --type=NodePort --port=8080 --dry-run=client  -o yaml               
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: my-dep
  name: webapp-service
spec:
  ports:
  - port: 8080
    protocol: TCP
    targetPort: 80
  selector:
    app: my-dep
  type: NodePort
status:
  loadBalancer: {}
```
Now you can edit the yaml file to add `NodePort` as well. Then create the service using `kubectl create -f filename.yaml`