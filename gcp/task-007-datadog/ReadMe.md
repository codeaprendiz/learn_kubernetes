Referenced Docs
1) https://www.datadoghq.com/blog/monitoring-kubernetes-with-datadog/



- Secret resource Created
```bash
kubectl create secret generic datadog-secret --from-literal api-key="2dd8*******************74d48f"
```

- Run the following commands
```bash
kubectl apply -f .
```

- Verification of agent
```bash
kubectl exec -it datadog-agent-sjl78 agent status
```


- Generate 32 bit 
```bash
echo -n 'epFDv5fNFeDBxLAUzl5O5kq7jmcg9y5v' | base64
ZXBGRHY1Zk5GZURCeExBVXpsNU81a3E3am1jZzl5NXY=
kubectl create secret generic datadog-auth-token --from-literal=token=ZXBGRHY1Zk5GZURCeExBVXpsNU81a3E3am1jZzl5NXY=
```

- Deploy the cluster agent
```bash
kubectl get pods -l app=datadog-cluster-agent
```



