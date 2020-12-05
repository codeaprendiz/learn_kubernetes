[Kubernetes Cluster](#Kubernetes Cluster)


## Kubernetes Cluster
- Set of nodes which may be physical or virtual
- on premise or on cloud 
- that host applications in the form of containers
 
### Worker Nodes
- Host Application as containers

### Master Node
- Manage, Plan, Schedule, Monitor Nodes

### ETCD Cluster
- A database that stores information in key value format 


### kube-scheduler
- Identifies the right node to place the container on
- based on container's resource requirements, worker node capacity etc

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
  
![](https://github.com/codeaprendiz/_assets/blob/master/kubernetes-kitchen/kubernetes-architecture.png)