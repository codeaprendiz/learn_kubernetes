
### To get the version of the cluster

All resources in kubernetes are grouped into different API groups.
Each of those resources have associated set of actions on them called VERBs

> Note: you will need to pass authentication in all the API calls

```bash
curl https://kube-master:6443/version
```


### To get the pods 

```bash
curl https://kube-master:6443/api/v2/pods
```

Similarly other API's which are used are

`/metrics` api is used to monitor the health of the cluster

`/logs` is used to integrating with the third party logging applications

`/api` core group where all the core functionality exists


### To get all the api-groups

```bash
curl http://localhost:6443 -k
```

alternatively, you can run

```bash
kubectl proxy
Starting to server on 127.0.0.1:8001

curl http://localhost:8001 -k   
```


### Authorization

When we share our cluster between different entities (dev team, qa team, admins) by logically partioning it
using namespaces, we want to restrict access to their namespaces alone. that is what authorization can help you within a cluster


- You can set the authorization mode using
- When you specify multiple modes, it will authorize in the order in which it is specified

```bash
ExecStart=/usr/local/bin/kube-apiserver \\
.
 --authorization-mode=Node, RBAC, Webhook \\
```