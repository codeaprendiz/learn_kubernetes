### We have an application running on our cluster. Let us explore it first. What image is the application using?

```bash
controlplane $ kubectl describe deployment web | egrep -i image
    Image:        nginx:alpine
```


### We decided to use a modified version of the application from an internal private registry. Update the image of the deployment to use a new image from myprivateregistry.com:5000
    
- The registry is located at myprivateregistry.com:5000. Don't worry about the credentials for now. We will configure them in the upcoming steps.
  
```bash
controlplane $ cat dep.yaml | egrep -i image | egrep -v "f:|If"
      - image: myprivateregistry.com:5000/nginx:alpine
```  

### Are the new PODs created with the new images successfully running?
    
```bash
controlplane $ kubectl get pods
NAME                   READY   STATUS             RESTARTS   AGE
web-85fcf65896-9xjkh   0/1     ImagePullBackOff   0          86s
```
    


### Create a secret object with the credentials required to access the registry
    
Name: private-reg-cred

Username: dock_user

Password: dock_password

Server: myprivateregistry.com:5000

Email: dock_user@myprivateregistry.com

```bash
$ kubectl create secret docker-registry private-reg-cred --docker-username=dock_user --docker-password=dock_password --docker-server=myprivateregistry.com:5000 --docker-email=dock_user@myprivateregistry.com
```


### Configure the deployment to use credentials from the new secret to pull images from the private registry

```bash
controlplane $ cat dep.yaml | egrep -i imagePullSecrets: -A 2 -B 6
      - image: myprivateregistry.com:5000/nginx:alpine
        imagePullPolicy: IfNotPresent
        name: nginx
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      imagePullSecrets:
      - name: private-reg-cred
      dnsPolicy: ClusterFirst
```