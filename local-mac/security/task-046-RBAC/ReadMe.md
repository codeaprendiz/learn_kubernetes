### Inspect the environment and identify the authorization modes configured on the cluster.
    
Check the kube-api server settings

```bash
$ kubectl describe pod kube-apiserver-controlplane -n kube-system | egrep -i "authorization"
      --authorization-mode=Node,RBAC
```

### How many roles exist in the default namespace?
    
```bash
$ kubectl get roles
No resources found in default namespace.
```

### How many roles exist in all namespaces together?
    
```bash
$ kubectl get roles --all-namespaces --no-headers | wc -l
12
```


### What are the resources the kube-proxy role in the kube-system namespce is given access to?

```bash
Name:         kube-proxy
Labels:       <none>
Annotations:  <none>
PolicyRule:
  Resources   Non-Resource URLs  Resource Names  Verbs
  ---------   -----------------  --------------  -----
  configmaps  []                 [kube-proxy]    [get]
```

### What actions can the kube-proxy role perform on configmaps
    
```bash
## get
```

### Which account is the kube-proxy role assigned to it?
    
```bash
controlplane $ kubectl describe rolebinding kube-proxy -n kube-system
Name:         kube-proxy
Labels:       <none>
Annotations:  <none>
Role:
  Kind:  Role
  Name:  kube-proxy
Subjects:
  Kind   Name                                             Namespace
  ----   ----                                             ---------
  Group  system:bootstrappers:kubeadm:default-node-token  
```


### A user dev-user is created. User's details have been added to the kubeconfig file. Inspect the permissions granted to the user. Check if the user can list pods in the default namespace.

- Use the --as dev-user option with kubectl to run commands as the dev-user

```bash
controlplane $ kubectl get pods --as dev-user
Error from server (Forbidden): pods is forbidden: User "dev-user" cannot list resource "pods" in API group "" in the namespace "default"
```


### Create the necessary roles and role bindings required for the dev-user to create, list and delete pods in the default namespace.

Use the given spec

Role: developer

Role Resources: pods

Role Actions: list

Role Actions: create

RoleBinding: dev-user-binding

RoleBinding: Bound to dev-user

```bash
controlplane $ cat role.yaml 
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: developer
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["create", "list"]

controlplane $ cat role-binding.yaml 
apiVersion: rbac.authorization.k8s.io/v1
# This role binding allows "jane" to read pods in the "default" namespace.
# You need to already have a Role named "pod-reader" in that namespace.
kind: RoleBinding
metadata:
  name: dev-user-binding
  namespace: default
subjects:
# You can specify more than one "subject"
- kind: User
  name: dev-user # "name" is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  # "roleRef" specifies the binding to a Role / ClusterRole
  kind: Role 
  name: developer 
  apiGroup: rbac.authorization.k8s.io

controlplane $ kubectl apply -f .
rolebinding.rbac.authorization.k8s.io/dev-user-binding created
role.rbac.authorization.k8s.io/developer created
```


### The dev-user is trying to get details about the dark-blue-app pod in the blue namespace. Investigate and fix the issue.

We have created the required roles and rolebindings, but something seems to be wrong.

```bash
$ kubectl get roles,rolebindings -n blue
$ kubectl describe role developer -n blue
$ kubectl edit role developer -n blue (add the pod name `daskbluepod` in the resourcNames sections)
```


### Grant the dev-user permissions to create deployments in the blue namespace.

- Remember to add both groups "apps" and "extensions"

```bash
controlplane $ cat /var/answers/dev-user-deploy.yaml
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: blue
  name: deploy-role
rules:
- apiGroups: ["apps", "extensions"]
  resources: ["deployments"]
  verbs: ["create"]

---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: dev-user-deploy-binding
  namespace: blue
subjects:
- kind: User
  name: dev-user
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: deploy-role
  apiGroup: rbac.authorization.k8s.io
```



### How many ClusterRoles do you see defined in the cluster?
    
```bash
controlplane $ kubectl get clusterrole --no-headers | wc -l
60
```


### How many ClusterRoleBindings exist on the cluster?
    
```bash
controlplane $ kubectl get clusterrolebindings --no-headers | wc -l
46
```

### What namespace is the cluster-admin clusterrole part of?
    
```bash
clusterwide and not part of namespace
```


### What user/groups are the cluster-admin role bound to?
    
```bash
controlplane $ kubectl get clusterrolebindings | grep cluster-admin
cluster-admin                                          ClusterRole/cluster-admin                                                          27m
permissive-binding                                     ClusterRole/cluster-admin   

controlplane $ kubectl describe clusterrolebinding cluster-admin  | egrep  -A 3 "Subjects"
Subjects:
  Kind   Name            Namespace
  ----   ----            ---------
  Group  system:masters 

controlplane $ kubectl describe clusterrolebinding permissive-binding   | egrep  -A 3 "Subjects"
Subjects:
  Kind   Name                    Namespace
  ----   ----                    ---------
  User   admin                   
controlplane $
```


### What level of permission does the cluster-admin role grant?
    
Inspect the cluster-admin role's privileges

```bash
controlplane $ kubectl describe clusterrole cluster-admin
Name:         cluster-admin
Labels:       kubernetes.io/bootstrapping=rbac-defaults
Annotations:  rbac.authorization.kubernetes.io/autoupdate: true
PolicyRule:
  Resources  Non-Resource URLs  Resource Names  Verbs
  ---------  -----------------  --------------  -----
  *.*        []                 []              [*]
             [*]                []              [*]
```


### A new user michelle joined the team. She will be focusing on the nodes in the cluster. Create the required ClusterRoles and ClusterRoleBindings so she gets access to the nodes.

```bash
$ kubectl apply -f .
clusterrole.rbac.authorization.k8s.io/my-role created
clusterrolebinding.rbac.authorization.k8s.io/read-secrets-global created

controlplane $ cat cr.yaml 
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  # "namespace" omitted since ClusterRoles are not namespaced
  name: my-role
rules:
- apiGroups: [""]
  #
  # at the HTTP level, the name of the resource for accessing Secret
  # objects is "secrets"
  resources: ["nodes"]
  verbs: ["get", "watch", "list"]

controlplane $ cat crb.yaml 
apiVersion: rbac.authorization.k8s.io/v1
# This cluster role binding allows anyone in the "manager" group to read secrets in any namespace.
kind: ClusterRoleBinding
metadata:
  name: read-secrets-global
subjects:
- kind: User
  name: michelle # Name is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: my-role
  apiGroup: rbac.authorization.k8s.io
```


### michelle's responsibilities are growing and now she will be responsible for storage as well. Create the required ClusterRoles and ClusterRoleBindings to allow her access to Storage.

- Get the API groups and resource names from command kubectl api-resources. Use the given spec.

ClusterRole: storage-admin

Resource: persistentvolumes

Resource: storageclasses

ClusterRoleBinding: michelle-storage-admin

ClusterRoleBinding Subject: michelle

ClusterRoleBinding Role: storage-admin

```bash
$ kubectl api-resources | egrep -i "persistent"
persistentvolumeclaims            pvc                                         true         PersistentVolumeClaim
persistentvolumes                 pv                                          false        PersistentVolume

controlplane $ cat cr.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  # "namespace" omitted since ClusterRoles are not namespaced
  name: storage-admin
rules:
- apiGroups: [""]
  #
  # at the HTTP level, the name of the resource for accessing Secret
  # objects is "secrets"
  resources: ["persistentvolumes", "storageclasses"]
  verbs: ["get", "watch", "list"]

controlplane $ cat crb.yaml
apiVersion: rbac.authorization.k8s.io/v1
# This cluster role binding allows anyone in the "manager" group to read secrets in any namespace.
kind: ClusterRoleBinding
metadata:
  name: michelle-storage-admin
subjects:
- kind: User
  name: michelle # Name is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: storage-admin
  apiGroup: rbac.authorization.k8s.io
```


