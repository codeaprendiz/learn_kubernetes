## Objective : 
### 1) To create user DAVE in group 'groupQA' in namespace default and give only Read access to this user.

- Running run-all.sh

```bash
$ ./run-all.sh groupQA R
Dev cluster
-------------------------------
          Resetting previous changes
-------------------------------
certificatesigningrequest.certificates.k8s.io "dev-csr" deleted
clusterrole.rbac.authorization.k8s.io "role-dev" deleted
clusterrolebinding.rbac.authorization.k8s.io "rolebinding-monitoring-ns" deleted
-------------------------------
          Client Cert Generation
-------------------------------
Generating RSA private key, 4096 bit long modulus
.........++++
.............++++
e is 65537 (0x010001)
-------------------------------
          kubeconfig & dave.key generation
-------------------------------
certificatesigningrequest.certificates.k8s.io/dev-csr created
NAME      AGE   REQUESTOR                CONDITION
dev-csr   1s    user@gmail.com   Pending
certificatesigningrequest.certificates.k8s.io/dev-csr approved
NAME      AGE   REQUESTOR                CONDITION
dev-csr   2s    user@gmail.com   Approved,Issued
clusterrole.rbac.authorization.k8s.io/role-dev created
clusterrolebinding.rbac.authorization.k8s.io/rolebinding-monitoring-ns created
-------------------------------
          Share the following files with the groupQA
          ./dev/groupQA/kubeconfig
          ./dev/groupQA/dave.key

          Initialization Steps
          $ export KUBECONFIG=$PWD/kubeconfig

          $ kubectl config set-credentials dave \
            --client-key=$PWD/dave.key \
            --embed-certs=true

-------------------------------
```

- At the client workstation
```bash
$ ls kubeconfig dave.key
dave.key   kubeconfig

$ export KUBECONFIG=$PWD/kubeconfig

$ kubectl config set-credentials dave \
>             --client-key=$PWD/dave.key \
>             --embed-certs=true
User "dave" set.

$ kubectl get pods -n kube-system                                                  
NAME                                                        READY   STATUS    RESTARTS   AGE
prometheus-to-sd-xx9nx                                      2/2     Running   0          14h

$ kubectl get pods -n default    
No resources found.

$ kubectl get namespace      
Error from server (Forbidden): namespaces is forbidden: User "dave" cannot list resource "namespaces" in API group "" at the cluster scope

$ kubectl delete pod prometheus-to-sd-xx9nx -n kube-system
Error from server (Forbidden): pods "prometheus-to-sd-xx9nx" is forbidden: User "dave" cannot delete resource "pods" in API group "" in the namespace "kube-system"
```