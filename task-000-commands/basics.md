

## Kubernetes Cluster
- Set of nodes which may be physical or virtual
- on premise or on cloud 
- that host applications in the form of containers

![](https://github.com/codeaprendiz/_assets/blob/master/kubernetes-kitchen/kubernetes-architecture.png)
 
### Worker Nodes
- Host Application as containers

### Master Node
- Manage, Plan, Schedule, Monitor Nodes

### ETCD Cluster
- A database that stores information in key value format 
- It is a simple, reliable, key-value store that is simple, secure and fast.
- You can download the binary of etcd and run it using `./etcd`. Its starts service on port 2379 by default.
  You can attach clients to the service to store and retrieve the data.
- The default client that comes with etcd is etcd control client  `./etcdctl set key1 value1`. And we can retrieve 
  the data using `./etcdctl get key1`
- The ETCD datastore stores information about the cluster like
    - Nodes, Pods, Configs, Secrets, Accounts, Roles, Bindings
- Every change we make to the cluster are updated in the etcd server. 
- Installing ETCD service
    - Manual : Install cluster from scratch
        - Download the binary and install in the master node yourself.
        - `--advertise-client-urls https://${{INTERNAL_IP}}:2379`: The address on which etcd listens. This should be configured in the `kube-api` server
          when it tries to contact the `etcd` service.
    - Install using `kube-adm`      
        - This deploys the `etcd` server for you as a pod in the `kube-system` namespace
- Kubernetes stores data in specific directory structure. The `root` directory is `/registry` and under that
  we have variour kubernetes contructs like minions, pods, replicasets, roles etc
- In highly available environment you will have multiple master nodes in a cluster and then you would also have 
  multiple etcd instances spread across the master nodes. In that case make sure that the etcd instances know 
  about each other by setting the right parameter in the `etcd` service configuration.
    - The `--initial-cluster controller-0=https://${CONTROLLER0_IP}:2380,controller-1=https://$}CONTROLLER1_IP}:2380 `    
- ETCDCTL is the CLI tool used to interact with ETCD.
  
    - ETCDCTL can interact with ETCD Server using 2 API versions - Version 2 and Version 3.  By default its set to use Version 2. Each version has different sets of commands.
      For example ETCDCTL version 2 supports the following commands:
    ```bash
    etcdctl backup
    etcdctl cluster-health
    etcdctl mk
    etcdctl mkdir
    etcdctl set
    ```
    - Whereas the commands are different in version 3
    ```bash
    etcdctl snapshot save 
    etcdctl endpoint health
    etcdctl get
    etcdctl put
    ```
    - To set the right version of API set the environment variable ETCDCTL_API command
    ```bash
    export ETCDCTL_API=3
    ```
    - Apart from that, you must also specify path to certificate files so that ETCDCTL can authenticate to the ETCD API Server. The certificate files are available in the etcd-master at the following path
    ```bash
    --cacert /etc/kubernetes/pki/etcd/ca.crt     
    --cert /etc/kubernetes/pki/etcd/server.crt     
    --key /etc/kubernetes/pki/etcd/server.key
    ```
  - To get all the keys stored by kubernetes
    ```bash
    kubectl exec etcd-master -n kube-system -- sh -c "ETCDCTL_API=3 etcdctl get / --prefix --keys-only --limit=10 --cacert /etc/kubernetes/pki/etcd/ca.crt --cert /etc/kubernetes/pki/etcd/server.crt  --key /etc/kubernetes/pki/etcd/server.key" 
    ```

### kube-scheduler
- Identifies the right node to place the container on
- based on container's resource requirements, worker node capacity etc
- The scheduler continously monitors the api-server. When ever there is a new node created, it realizes and assigns it to appropriate node and communicates back to the 
  `kube-api` server. 

### Node Controller
- Takes care of nodes, responsible for onboarding new nodes to the cluster, handlying
  situations when nodes become unavailable or gets destroyed
  
### Replication- Controller
- If desired number of containers are running at any point in time in a replication group.


### kube-apiserver
- Primary management component of kubernetes
- orchestrating all operations in the cluster
- it exposes the kubernetes api which is used by external users to perform
  management operations on the cluster
- When you run a kubectl (kube control) command the kube-control utility reaches to the kube-api server. The kube-api server then authenticates and validates the
 request. It then retrieves the data from the etcd cluster and then responds back with the required information.
- We don't need to use the kube-control command line always, instead we can also invoke the api's directly by sending HTTP requests.

![](https://github.com/codeaprendiz/_assets/blob/master/kubernetes-kitchen/flow-user-kube-api-server-etcd-cluster-and-back.png)
```bash
kubectl get nodes
curl -X POST /api/v1/namespaces/defaults/pods/...[other]
```
  
### Container-Runtime Engine
- We need a software that can run the containers i.e. container runtime engine (eg docker).
- We need docker or its equivalent to be installed on all nodes of the cluster including the master nodes
- kubernetes supports other runtime engines as well like containerd

### kubelet
- Its an agent that runs on each node in the cluster
- It listens for instructions from the kube-api server and deploys or destroys the 
  containers as required
- kube-api server periodically fetches status reports from the kubelet to monitor the 
  status of the nodes on them 
  
### Kube-proxy service
- enables the communication between the worker nodes
- ensures that the necessary rules are in place on the worker nodes to allow the
  containers running on them to reach each other
  
