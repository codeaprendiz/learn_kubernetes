
- Create a deployment nginx without using yaml file

```bash
kubectl create deployment httpd-frontend --image=nginx
```

- Scale the deployment to 3 replicas without using yaml

```bash
$ kubectl scale deployment httpd-frontend --replicas=3
deployment.apps/httpd-frontend scaled
```

- Create a yaml deployment file of `nginx`
```bash
$ kubectl create deployment httpd-frontend --image=nginx --dry-run=client -o yaml > nginx-deployment.yaml
```