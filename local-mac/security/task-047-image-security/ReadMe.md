### Images

```yaml
image: docker.io/nginx/nginx
```
Here
- docker.io - Registry by default
- nginx - user account
- nginx - image repository

Other registries examples
- gcr.io/


### How the images are downloaded from private registry

- Create a secret

```bash
$ kubectl create secret docker-registry regcred \
  --docker-server=private-registry.io \ 
  --docker-username=registry-user \
  --docker-password=registry-password \
  --docker-email=registry-user@org.com
```



```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
  - name: nginx
    image: private-registry.io/apps/internal-app
  imagePullSecrets:
  - name: regcred
```
