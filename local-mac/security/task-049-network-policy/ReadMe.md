### How many network policies do you see in the environment?
    
We have deployed few web applications, services and network policies. Inspect the environment.

```bash
controlplane $ kubectl get pods
NAME       READY   STATUS    RESTARTS   AGE
external   1/1     Running   0          2m12s
internal   1/1     Running   0          2m12s
mysql      1/1     Running   0          2m12s
payroll    1/1     Running   0          2m12s

controlplane $ kubectl get svc
NAME               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
db-service         ClusterIP   10.108.112.31    <none>        3306/TCP         2m25s
external-service   NodePort    10.106.136.214   <none>        8080:30080/TCP   2m25s
internal-service   NodePort    10.107.7.1       <none>        8080:30082/TCP   2m25s
kubernetes         ClusterIP   10.96.0.1        <none>        443/TCP          39m
payroll-service    NodePort    10.110.30.83     <none>        8080:30083/TCP   2m25s

controlplane $ kubectl get networkpolicies
NAME             POD-SELECTOR   AGE
payroll-policy   name=payroll   2m46s
```    


### What is the name of the Network Policy?
    
```bash
controlplane $ kubectl get networkpolicies
NAME             POD-SELECTOR   AGE
payroll-policy   name=payroll   2m46s
```

### Which pod is the Network Policy applied on?
    
```bash
controlplane $ kubectl get netpol
NAME             POD-SELECTOR   AGE
payroll-policy   name=payroll   11m

controlplane $ kubectl get pod -l name=payroll
NAME      READY   STATUS    RESTARTS   AGE
payroll   1/1     Running   0          12m
```



### What type of traffic is this Network Policy configured to handle?
    
```bash
controlplane $ kubectl describe netpol payroll-policy 
Name:         payroll-policy
Namespace:    default
Created on:   2021-02-04 18:53:42 +0000 UTC
Labels:       <none>
Annotations:  <none>
Spec:
  PodSelector:     name=payroll
  Allowing ingress traffic:
    To Port: 8080/TCP
    From:
      PodSelector: name=internal
  Not affecting egress traffic
  Policy Types: Ingress
```


### What is the impact of the rule configured on this Network Policy?
    
```bash
Traffic from internal to payrool is allowed
Internal pod can access port 8080 on payroll pod
```



### Create a network policy to allow traffic from the 'Internal' application only to the 'payroll-service' and 'db-service'


Use the spec given on the right. You might want to enable ingress traffic to the pod to test your rules in the UI.

Policy Name: internal-policy

Policy Types: Egress

Egress Allow: payroll

Payroll Port: 8080

Egress Allow: mysql

MYSQL Port: 3306


```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: internal-policy
  namespace: default
spec:
  podSelector:
    matchLabels:
      name: internal
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          name: mysql
    ports:
    - protocol: TCP
      port: 3306
  - to:
    - podSelector:
        matchLabels:
          name: payroll
    ports:
    - protocol: TCP
      port: 8080
```