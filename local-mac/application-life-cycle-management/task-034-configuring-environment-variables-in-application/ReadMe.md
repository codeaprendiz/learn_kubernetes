### Configuring the environment variables in applications

- plain test

```yaml
env:
  - name: APP_NAME
    value: test-app
```

- configmap
```yaml
env:
  - name: APP_NAME
    valueFrom:
      configMapKeyRef: ...
```

- secrets
```yaml
env:
  - name: APP_NAME
    valueFrom:
      secretKeyRef: ...
```

### Creating configmaps Imperative Approach

- Here is the command format
```bash
kubectl create configmap \
  <config-name>  --from-literal=<key>=<value>
```

- Consider the following example
```bash
kubectl create configmap \
  app-config --from-literal=APP_NAME=test-app
```

- If you want to take input from the file


```bash
kubectl create configmap \
  app-config --from-file=<path_to_file>
```

```bash
kubectl create configmap \
  app-config --from-file=app_config.properties
```


### Creating configmaps Declarative Approach

my-configmap.yaml
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-configmap
data:
    APP_NAME: test_app
    APP_ENV: dev
```

- Apply the configmap
```bash
kubectl apply -f my-configmap.yaml
```

- To view the configmap
```bash
kubectl get configmaps
```

### How to inject the config map in pods

- Env
```yaml
    envFrom:
      - configMapRef:
          name: app-config
```

- Single Env
```yaml
env:
  name: APP_COLOR
  valueFrom:
    configMapKeyRef:
      name: app-config
      key: APP_COLOR
```

- Volume

```yaml
volumes:
- name: app-config-volume
  secret:
    secretName: app-config
```

For example 
- Injecting the above `app-configmap` in the pod
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
      - configMapRef:
          name: app-configmap
```


### What is the environment variable name set on the container in the pod?

```bash
$ kubectl describe pod webapp-color  | grep -A 2 -i env
    Environment:
      APP_COLOR:  pink
    Mounts:
```

### Describe the configmap db-config

```bash
controlplane $ kubectl describe configmap db-config
Name:         db-config
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
DB_HOST:
----
SQL01.example.com
DB_NAME:
----
SQL01
DB_PORT:
----
3306
Events:  <none>
```



### Create a new ConfigMap for the 'webapp-color' POD. Use the spec given on the right.

- ConfigName Name: webapp-config-map
- Data: APP_COLOR=darkblue

```bash
$ kubectl create configmap webapp-config-map --from-literal=APP_COLOR=darkblue
configmap/webapp-config-map created
```

### Update the environment variable on the POD use the newly created ConfigMap

- Pod Name: webapp-color
- EnvFrom: webapp-config-map

```bash
controlplane $ kubectl get pod webapp-color -o yaml > pod.yaml

controlplane $ kubectl apply -f pod.yaml
pod/webapp-color created

controlplane $ cat pod.yaml | grep -A 3 -i envfrom
    envFrom:
      - configMapRef:
          name: webapp-config-map
    name: webapp-color
```




