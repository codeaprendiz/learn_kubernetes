
- Format of the `kubeconfig` file
- We can specifiy multiple cluster, users who can access those clusters and the context to link them
```yaml
apiVersion: v1
kind: Config

## This tells the current context being used
current-context: dev-user@google

clusters:
- name: my-kube-playground
  cluster:
## you can also use certificate-authority-data field to specify the data in base64 encoded format
## instead of certificate-authority field
    certificate-authority: ca.crt
    server: https://my-kube-playground:6443
- name: development
- name: production
- name: google

contexts:
- name: my-kube-admin@my-kube-playground
  context:
    cluster: my-kube-playground
    user: my-kube-admin
- name: dev-user@google
- name: prod-user@google

users:
- name: my-kube-admin
  user:
    client-certificate: admin.crt
    client-key: admin.key
- name: dev-user
- name: prod-user
```

To view the current config

```bash
kubectl config view
```


- To specifiy the kubeconfig file

```bash
kubectl config view --kubeconfig=my-custom-config
```

- How to change the context then?

```bash
kubectl config use-context prod-user@production
```

- Check other options in kubectl config

```bash
$ kubectl config -h                             
```

- Can we configure a context to swtich to a particular namespace ?

Yes it can be specified as follows. When you switch to this context, you would automaticall
swtich to the specified namespace as well.
```yaml
contexts:
- name: my-kube-admin@my-kube-playground
  context:
    cluster: my-kube-playground
    user: my-kube-admin
    namespace: finance
```


### Where is the default kubeconfig file located in the current environment?
    
    
```bash
controlplane $ ls .kube
cache  config
controlplane $ pwd
/root
```

### How many clusters are defined in the default kubeconfig file?
    
```bash
controlplane $ cat .kube/config  | egrep -i "cluster:"
- cluster:
    cluster: kubernetes
```


### How many Users are defined in the default kubeconfig file?
    
```bash
controlplane $ cat .kube/config  | egrep -i "user:"
    user: kubernetes-admin
  user:
```

### How many contexts are defined in the default kubeconfig file?
    
```bash
controlplane $ cat .kube/config  | egrep -i "context:"
- context:
current-context: kubernetes-admin@kubernetes
```

### What is the user configured in the current context?
    
```bash
controlplane $ cat .kube/config  | egrep -i "context:"
- context:
current-context: kubernetes-admin@kubernetes
```

### What is the name of the cluster configured in the default kubeconfig file?
    
```bash
controlplane $ cat .kube/config  | egrep -i "cluster"
clusters:
- cluster:
    cluster: kubernetes
```


### A new kubeconfig file named 'my-kube-config' is created. It is placed in the /root directory. How many clusters are defined in the kubeconfig file?

```bash
## 4 
controlplane $ cat my-kube-config  | grep -i cluster:
  cluster:
  cluster:
  cluster:
  cluster:
    cluster: development
    cluster: kubernetes-on-aws
    cluster: production
    cluster: test-cluster-1
```

### How many contexts are configured in the 'my-kube-config' file?
    
```bash
controlplane $ cat my-kube-config  | grep -i "context"
contexts:
  context:
  context:
  context:
  context:
current-context: test-user@development
```

### What user is configured in the 'research' context?
    
```bash
controlplane $ cat my-kube-config  | grep -i "research" -A 4 -B 4
  context:
    cluster: production
    user: test-user

- name: research
  context:
    cluster: test-cluster-1
    user: dev-user
```


### What is the name of the client-certificate file configured for the 'aws-user'?
    
```bash
controlplane $ cat my-kube-config  | grep -i "aws-user" -B 4
- name: aws-user
  user:
    client-certificate: /etc/kubernetes/pki/users/aws-user/aws-user.crt
    client-key: /etc/kubernetes/pki/users/aws-user/aws-user.key
```


### What is the current context set to in the 'my-kube-config' file?
    
```bash
controlplane $ cat my-kube-config | egrep -i "current-context"
current-context: test-user@development
```

### I would like to use the dev-user to access test-cluster-1. Set the current context to the right one so I can do that.

Once the right context is identified, use the 'kubectl config use-context' command.


```bash
controlplane $ cat my-kube-config | grep research -B 4
  name: aws-user@kubernetes-on-aws
- context:
    cluster: test-cluster-1
    user: dev-user
  name: research

controlplane $ kubectl config --kubeconfig=/root/my-kube-config use-context research
Switched to context "research".

controlplane $ cat my-kube-config | egrep -i "current-context"current-context: research
```


### We don't want to have to specify the kubeconfig file option on each command. Make the my-kube-config file the default kubeconfig.

```bash
controlplane $ cp -rfp my-kube-config .kube/config   
```

### With the current-context set to research, we are trying to access the cluster. However something seems to be wrong. Identify and fix the issue.


Try running the kubectl get pods command and look for the error. All users certificates are stored at /etc/kubernetes/pki/users

```bash
controlplane $ kubectl get pods
error: unable to read client-cert /etc/kubernetes/pki/users/dev-user/developer-user.crt for dev-user due to open /etc/kubernetes/pki/users/dev-user/developer-user.crt: no such file or directory
controlplane $ ls /etc/kubernetes/pki/users

controlplane $ ls /etc/kubernetes/pki/users/dev-user/
dev-user.crt  dev-user.csr  dev-user.key

controlplane $ cat config | egrep -i client-certificate
    client-certificate: /etc/kubernetes/pki/users/aws-user/aws-user.crt
    client-certificate: /etc/kubernetes/pki/users/dev-user/dev-user.crt
    client-certificate: /etc/kubernetes/pki/users/test-user/test-user.crt

```