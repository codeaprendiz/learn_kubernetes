### PRE-REQUISITE 

- [Install vagrant for mac](https://www.vagrantup.com/downloads)
- [Install virtual box for mac](https://www.virtualbox.org/wiki/Downloads)
- [kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)

- Check the status 

```bash
$ vagrant status
Current machine states:

kubemaster                not created (virtualbox)
kubenode01                not created (virtualbox)
kubenode02                not created (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
```


- Bring up the vms

```bash
$ vagrant up
Bringing machine 'kubemaster' up with 'virtualbox' provider...
Bringing machine 'kubenode01' up with 'virtualbox' provider...
Bringing machine 'kubenode02' up with 'virtualbox' provider...
==> kubemaster: Importing base box 'ubuntu/bionic64'...
==> kubemaster: Matching MAC address for NAT networking...
==> kubemaster: Setting the name of the VM: kubemaster
==> kubemaster: Clearing any previously set network interfaces...
.
.

```

- Check the status again

```bash
$ vagrant status
Current machine states:

kubemaster                running (virtualbox)
kubenode01                running (virtualbox)
kubenode02                running (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
```

- SSH into master and other nodes

```bash
$ vagrant ssh kubemaster
vagrant@kubemaster:~$ uptime
 18:23:02 up 12 min,  1 user,  load average: 0.00, 0.00, 0.00

$ vagrant ssh kubenode01
vagrant@kubenode01:~$ 

$ vagrant ssh kubenode02
vagrant@kubenode02:~$ 
```

- Letting iptables see bridged traffic  

```bash
vagrant@kubemaster:~$ lsmod | grep br_netfilter
vagrant@kubemaster:~$ 
vagrant@kubemaster:~$ sudo modprobe br_netfilter
vagrant@kubemaster:~$ lsmod | grep br_netfilter
br_netfilter           24576  0
bridge                155648  1 br_netfilter

vagrant@kubenode01:~$ lsmod | grep br_netfi
vagrant@kubenode01:~$ sudo modprobe br_netfilter
vagrant@kubenode01:~$ lsmod | grep br_netfi
br_netfilter           24576  0
bridge                155648  1 br_netfilter

vagrant@kubenode02:~$ lsmod | grep br_netfi
vagrant@kubenode02:~$ sudo modprobe br_netfilter
vagrant@kubenode02:~$ lsmod | grep br_netfi
br_netfilter           24576  0
bridge                155648  1 br_netfilter

```

- ensure net.bridge.bridge-nf-call-iptables is set to 1 in your sysctl config, e.g.

```bash
vagrant@kubemaster:~$ cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
> br_netfilter
> EOF
br_netfilter

vagrant@kubenode01:~$ cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
> br_netfilter
> EOF
br_netfilter

vagrant@kubenode02:~$ cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
> br_netfilter
> EOF
br_netfilter


vagrant@kubemaster:~$ cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
> net.bridge.bridge-nf-call-ip6tables = 1
> net.bridge.bridge-nf-call-iptables = 1
> EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1


vagrant@kubenode01:~$ cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
> net.bridge.bridge-nf-call-ip6tables = 1
> net.bridge.bridge-nf-call-iptables = 1
> EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1

vagrant@kubenode02:~$ cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
> net.bridge.bridge-nf-call-ip6tables = 1
> net.bridge.bridge-nf-call-iptables = 1
> EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1

### on all nodes
sudo sysctl --system
```


- Install container-runtime [docker](https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker)

```bash
### Switch to sudo in all nodes


### on all nodes
sudo apt-get update && sudo apt-get install -y \
  apt-transport-https ca-certificates curl software-properties-common gnupg2


### on all nodes, install gpg keys
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key --keyring /etc/apt/trusted.gpg.d/docker.gpg add -

### on all nodes
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"


### on all nodes
sudo apt-get update && sudo apt-get install -y \
  containerd.io=1.2.13-2 \
  docker-ce=5:19.03.11~3-0~ubuntu-$(lsb_release -cs) \
  docker-ce-cli=5:19.03.11~3-0~ubuntu-$(lsb_release -cs)



### Exit sudo and on all nodes run
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

### on all
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker

```


- Installing kubeadm, kubelet and kubectl 

```bash

### On all nodes

sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```


- [Creating a cluster with kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)

- Run only on master as root. You will get the `kubeadm join` command as output. Keep a not of the same.

```bash
root@kubemaster:/home/vagrant# kubeadm init --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address=192.168.56.2
# Then you can join any number of worker nodes by running the following on each as root:
#
# kubeadm join 192.168.56.2:6443 --token w6mva4.ykgruoghl14ul4hn \
#    --discovery-token-ca-cert-hash sha256:2e96e3b2d505f0a2f77844d7ef92b2fdbb99786ef74221401652ef34daafcb78 
### exit root
vagrant@kubemaster:~$   mkdir -p $HOME/.kube
vagrant@kubemaster:~$   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
vagrant@kubemaster:~$   sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

- Currently the status of the cluster

```bash
vagrant@kubemaster:~$ kubectl get nodes
NAME         STATUS     ROLES                  AGE     VERSION
kubemaster   NotReady   control-plane,master   4m44s   v1.20.2
```

- [Install pod network add on](https://www.weave.works/docs/net/latest/kubernetes/kube-addon/)

```bash
vagrant@kubemaster:~$ kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
serviceaccount/weave-net created
clusterrole.rbac.authorization.k8s.io/weave-net created
clusterrolebinding.rbac.authorization.k8s.io/weave-net created
role.rbac.authorization.k8s.io/weave-net created
rolebinding.rbac.authorization.k8s.io/weave-net created
daemonset.apps/weave-net created
```

- Now copy and run the command we saved on both the worker nodes

```bash
root@kubenode01:/home/vagrant# kubeadm join 192.168.56.2:6443 --token w6mva4.ykgruoghl14ul4hn \
>     --discovery-token-ca-cert-hash sha256:2e96e3b2d505f0a2f77844d7ef92b2fdbb99786ef74221401652ef34daafcb78 
[preflight] Running pre-flight checks
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
```

- on second node

```bash
root@kubenode02:/home/vagrant# kubeadm join 192.168.56.2:6443 --token w6mva4.ykgruoghl14ul4hn     --discovery-token-ca-cert-hash sha256:2e96e3b2d505f0a2f77844d7ef92b2fdbb99786ef74221401652ef34daafcb78
.
.
This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.
```

- check the status of the nodes now
```bash
vagrant@kubemaster:~$ kubectl get nodes
NAME         STATUS   ROLES                  AGE     VERSION
kubemaster   Ready    control-plane,master   23m     v1.20.2
kubenode01   Ready    <none>                 3m38s   v1.20.2
kubenode02   Ready    <none>                 2m59s   v1.20.2
```

- create nginx pod

```bash
vagrant@kubemaster:~$ kubectl run nginx --image=nginx
pod/nginx created

vagrant@kubemaster:~$ kubectl get pods
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          23s
```

- you can destroy the cluster using

```bash
$ vagrant destroy       
    kubenode02: Are you sure you want to destroy the 'kubenode02' VM? [y/N] y
==> kubenode02: Forcing shutdown of VM...
==> kubenode02: Destroying VM and associated drives...
    kubenode01: Are you sure you want to destroy the 'kubenode01' VM? [y/N] y
==> kubenode01: Forcing shutdown of VM...
==> kubenode01: Destroying VM and associated drives...
    kubemaster: Are you sure you want to destroy the 'kubemaster' VM? [y/N] y
==> kubemaster: Forcing shutdown of VM...
==> kubemaster: Destroying VM and associated drives...
```