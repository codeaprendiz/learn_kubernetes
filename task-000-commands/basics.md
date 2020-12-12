
- [Kubernetes Cluster](#Kubernetes Cluster)
    - [Worker Nodes](#Worker Nodes)
    - [ETCD Cluster](#ETCD Cluster)
    - [kube-scheduler](#kube-scheduler)
    - [Node Controller](#Node Controller)
        - [Replication-Controller](#Replication-Controller)
    - [kube-apiserver](#kube-apiserver)    
    - [Container-Runtime Engine](#Container-Runtime Engine)
    - [kubelet](#kubelet)
    - [Kube-proxy service](#Kube-proxy service)
    - [Kube-controller Manager](#Kube-controller Manager)
    - [pod](#pod)

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
- It is only responsible for deciding which pods goes on which node. It does actually places the pods on the nodes.
  - It first filters the nodes which cannot accomodate the request
  - Then it runs functions which decide which node will be the best fit for the placement of the pod on the node. It ranks the nodes based on this.
  - You can write your own scheduler as well.
- How to install the kube-scheduler
  - Download the kube-scheduler binary from the kubernetes release page and install it as service.
  ```bash
     wget https://../kube-scheduler
  ```
 - Where you can view the kube-scheduler server options
   - If you set it up using the kube-adm tool which  deploys the kube-scheduler as a pod in the kube-system namespace on the master node, you can login into the pod
     and view the options at the following locations
     ```bash
     cat /etc/kubernetes/manifests/kube-scheduler.yaml
     ```
   - You can also see the running process by listing the processes running on the master node and then searching for the kube-scheduler process
   ```bash
     ps -aux | grep kube-scheduler
   ```
     

![](https://github.com/codeaprendiz/_assets/blob/master/kubernetes-kitchen/kube-scheduler.png)

### Node Controller
- Takes care of nodes, responsible for onboarding new nodes to the cluster, handlying
  situations when nodes become unavailable or gets destroyed
  
### Replication-Controller
- If desired number of containers are running at any point in time in a replication group.


### kube-apiserver
- Primary management component of kubernetes
- orchestrating all operations in the cluster
- it exposes the kubernetes api which is used by external users to perform
  management operations on the cluster
- When you run a kubectl (kube control) command the kube-control utility reaches to the kube-api server. The kube-api server then authenticates and validates the
 request. It then retrieves the data from the etcd cluster and then responds back with the required information.
- We don't need to use the kube-control command line always, instead we can also invoke the api's directly by sending HTTP requests.
- kube-api server is available as a binary in kubernetes release page. If not already present on the master node then you  need
  to download and configure it on the master node.

![](https://github.com/codeaprendiz/_assets/blob/master/kubernetes-kitchen/flow-user-kube-api-server-etcd-cluster-and-back.png)
```bash
kubectl get nodes
curl -X POST /api/v1/namespaces/defaults/pods/...[other]
```
- The kube-api server is responsible for 
  - Authenticate User
  - Validate Request
  - Retrieve data and Update data on ETCD cluster
  - Scheduler uses the api server to perform updates in the cluster
  - Kubelet uses the api server to perform updates in the cluster
  
- run time arguments worth knowing
  - `--etcd-servers=https://127.0.0.1:2379` - how the kubeapi server connects to the etcd server
- view kube-api server options in existing cluster
  - If you deploy the cluster using kubeadm which deploys the `kube-api` server as a pod in the namespace `kube-system`
        - `kubectl get pods -n kube-system` - Login into this pod and see the options at 
          - `cat /etc/kubernetes/manifests/kube-apiserver.yaml`
  - In non kubeadm set you can view the options by following command
        - `cat /etc/systemd/system/kube-apiserver.service`
        - You can also search for the kube-apiserver process on the master node and list the corresponding options
          `ps -aux | grep kube-apiserver`
  
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
- The kubelet in the kubernetes worker node registers the node with the kuernetes cluster. When it receives an instruction to load a container or a pod on the node
  it requests the container runtime engine (like docker) to pull the required image and run an instance and then continues to monitor the state of the pod and containers
  in it and reports to the kube-api server on timely basis.
- Install kubelet
  - Installing using kubeadm (kubeadm does not automatically deploy the kubelet). You can download the binary, install and run it as a service
  ```bash
  wget https://../kubelet
  ```
  You can view the running process and effective options by listing the process on the worker nodes
  ```bash
  ps -aux | grep kubelet
  ```
![](https://github.com/codeaprendiz/_assets/blob/master/kubernetes-kitchen/kubelet-kube-api-server.png)  

  
### Kube-proxy service
- enables the communication between the worker nodes
- ensures that the necessary rules are in place on the worker nodes to allow the
  containers running on them to reach each other
- within a kubenetes cluster every pod can reach every other pod. This is accomplished by deploying a pod-networking solution to the cluster.
  **Pod Network**
![](https://github.com/codeaprendiz/_assets/blob/master/kubernetes-kitchen/kube-proxy-pod-network.png)    
  - It is an internal virtual network that expands across all the nodes within the cluster through which all the pods are conntected.
  - If we have a web-application deployed on one node and a database application deployed on another node. Then the web-application can reach
    the database application using the IP of the database. But there is not guarante that the IP of the database would remain the same. That is why
    we expose the database application by using a service.
  - The service does not join the same POD network because the service is not an actual thing. It does not have a container like PODs so it doesn't have any interface
    or an actively listening process. It is a virtual component that only lives in kubernetes memory
- Kube-proxy is a process that run on each node in the kubernetes cluster. Its job is to look for new services and everytime a new service is created it creates appropriate 
  rule on each node to forward traffic to those services to the backend pods.
- It creates IP table rules on each node in the cluster to forward traffic heading to the IP of the service.   
  - In the following case it has created rules [1.2.3.6|1.2.3.5] in each of the nodes saying that traffic trying to reach the IP of the service 1.2.3.6 should
    be forwarded to 1.2.3.5

![](https://github.com/codeaprendiz/_assets/blob/master/kubernetes-kitchen/kube-proxy.png)

- Installing `kube-proxy`
  - download the kube-proxy from the kubernetes release page, install it and run it as a service    
  ```bash
  wget https://.../kube-proxy
  ```
- In kubeadm, the kube-proxy is deployed as a daemonset and therefor on each node in the cluster.
  
  
### Kube-controller Manager
-  Manager various controllers in kubernetes
- A controller is a process which continuously monitors the state of various components within the system and works towards 
  bringing the whole system towards the desired functioning state.
- For Example 
  - The *Node controller* is responsible for monitoring the status of the nodes and take the necessary action to keep the application running.
    It does that through the kube-api server.
  - The node controller checks the status of the nodes every 5 seconds, in this way the node controller can monitor the status of the nodes.
  - If it stops receiving heartbeat from a node, the node is marked as unreachable. But it waits for 40s before marking it as 
    unreachable. After a node is marked as unreachable it waits for 5 minutes for the node to come backup. If it doesn't it removes
    the pod assigned to that node and provisions them on the healthy ones if the pods are part of the replica set.
> Node Monitor Period = 5s

> Node Monitor Grace Period = 40s

> Pod Eviction Timeout = 5m

```bash
$ kubectl get nodes          
NAME       STATUS       ROLES   AGE    VERSION
worker-1   Ready       <none>   10d    v1.19.4
worker-2   NotReady    <none>   10d    v1.19.4
```   

![](https://github.com/codeaprendiz/_assets/blob/master/kubernetes-kitchen/Controllers-node-controller.png)
  
  - The *Replication Controller* is responsible to monitoring the status of the replicasets and ensuring that the desired 
    number of pods are always available within the set. If a pod dies it creates another one.
    
  - In the same way there are many such controllers within kubernetes like deployment-controller,
    namespace-controller, job-controller etc
- All these controllers are packaged in a single process know as `Kube-Controller-Manager`. 
- How to install the kube-controller-manager
  - Download the `kube-controller-manager` binary from the kubernetes release page.
    `wget https://../kube-controller-manager`
  - Extract it and run it as a service.
  - Options worth noting down
  ```bash
    --node-monitor-period=5s
    --node-monitor-grace-period=40s
    --pod-eviction-timeout=5m0s
    --controllers stringSlice  Default:[*]
  ``` 
  - The last option you saw is to enable which all controllers you want to enable. By default
    all of them are enabled. 
- So how do you view the kube-controller-manager's server options
  - If installed using `kubeadm`. The kubeadm deploys the kube-controller-manager as a pod in the 
    namespace kube-system on the master node. You can see these options indside the pod at the following
    location
    ```bash
    cat /etc/kubernetes/manifests/kube-controller-manager.yaml
    ```   
  - In non kubeadm set up you can view those options at the following location
    ```bash
    cat /etc/systemd/system/kube-controller-manager.service
    ```   
  - You can also see the running process and the effective options by listing the processes on the master
    node and searching for the kube-controller-manager
    ```bash
    ps -aux | grep kube-controller-manager
    ```
