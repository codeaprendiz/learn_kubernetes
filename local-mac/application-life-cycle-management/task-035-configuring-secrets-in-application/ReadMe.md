### Ways of creating secrets

#### Imperative approach

> kubectl create secret generic <secret-name> --from-literal=<key>=<value>

```bash
kubectl create secret generic app-secret \
  --from-literal=DB_HOST=localhost \
  --from-literal=DB_PORT=4200
```

> kubectl create secret generic <secret-name> --file=<path_to_file>


#### Declarative approach

app-secret-file.yaml
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
data:
## You have to specify the values in encoded format
##                  $ echo "localhost" | base64                        
##                  bG9jYWxob3N0Cg==
##                  $ echo "4022" | base64
##                  NDAyMgo=
  DB_HOST: bG9jYWxob3N0Cg==
  DB_PORT: NDAyMgo=
```

- Now create a secret using

```bash
kubectl create -f app-secret-file.yaml
```

- To view the secret you can use the following command

```bash
kubectl get secrets
```

### Configuring the secrets in pods

- Injecting the above `app-secret` in the pod
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-name
spec:
  containers:
  - name: container-name
    image: ubuntu
    envFrom:
      - secretRef:
          name: app-secret
```

### Ways of Injecting Secrets

- Env
```yaml
    envFrom:
      - secretRef:
          name: app-secret
```

- Single Env
```yaml
env:
  name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: app-secret
      key: db_password
```

- Volume

```yaml
volumes:
- name: app-secret-volume
  secret:
    secretName: app-secret
```


### How many Secrets exist on the system in default namespace?

```bash
$ kubectl get secrets
NAME                  TYPE                                  DATA   AGE
default-token-4jp2f   kubernetes.io/service-account-token   3      2m49s
```

### How many secrets are defined in the 'default-token' secret?
    
```bash
$ kubectl describe secret default-token-4jp2f
Name:         default-token-4jp2f
Namespace:    default
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: default
              kubernetes.io/service-account.uid: d5dbb05b-da71-4a01-ad1b-989aeabd2255

Type:  kubernetes.io/service-account-token

Data
====
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6InVpZ1dYQy1uWTRkVFMtZFJ3YXRQXy1KMUtZU2hhaHRFdjMzbkYtT0E2bHcifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6ImRlZmF1bHQtdG9rZW4tNGpwMmYiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiZGVmYXVsdCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImQ1ZGJiMDViLWRhNzEtNGEwMS1hZDFiLTk4OWFlYWJkMjI1NSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpkZWZhdWx0OmRlZmF1bHQifQ.KUy-D9lRc813qgpRPOcNC89bQ_ZSU36jstp5CUnS1madWYonLtGs_zOt0BiJ9dR57T-fjvpboO_9uh3SSsqaxFm9stcv6Yg96TDGnGZHrhfbFub8mcryjqTgCW_lP5siwiFnm3cCVUgzUE6PCZ6EnPn_X3QyFr3GW8oCvtE1ZD2yh1jzFTD_PCihbd4mr282b6KCEjwrCh80buJ82a221rgr4_TSLL8B73lfjrSU9IX5XydhZ5-ezQBWo9guRQrz7OJCDawnJ36x3qFRLTRrpntDwkjZVu6BRtQiGDwxtkHoxy1raaCydpfsyUIuqhnneqCED7215IHT_H_CqfW7eQ
ca.crt:     1066 bytes
namespace:  7 bytes
```


### The reason the application is failed is because we have not created the secrets yet. Create a new Secret named 'db-secret' with the data given(on the right).

- Secret Name: db-secret
- Secret 1: DB_Host=sql01
- Secret 2: DB_User=root
- Secret 3: DB_Password=password123


```bash
$ kubectl create secret generic db-secret --from-literal=DB_Host=sql01 --from-literal=DB_User=root --from-literal=DB_Password=password123
secret/db-secret created
```


### Configure webapp-pod to load environment variables from the newly created secret.
    
- Pod name: webapp-pod
- Image name: kodekloud/simple-webapp-mysql
- Env From: Secret=db-secret

```bash
controlplane $ kubectl get pods webapp-pod -o yaml > pod.yaml
controlplane $ kubectl explain pod --recursive | less | grep -i envfrom -A 4
         envFrom        <[]Object>
            configMapRef        <Object>
               name     <string>
               optional <boolean>
            prefix      <string>

controlplane $ vi pod.yaml
controlplane $ kubectl apply -f pod.yaml
pod/webapp-pod created

controlplane $ cat pod.yaml | grep -i envfrom -A 2
    envFrom:
    - secretRef:
        name: db-secret
```