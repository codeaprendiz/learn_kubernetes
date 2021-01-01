
- How many pods have the following labels `du=finanace` in default namespace
```bash
$ kubectl get pods -l bu=finance
```

- How many objects have label `env=prod` including PODs, ReplicaSets and any other objects?
```bash
$ kubectl get all -l env=prod --no-headers | wc -l
```

- Identify the POD which is part of the prod environment, the finance BU and of frontend tier?
```bash
$ kubectl get pod -l env=prod,bu=finance,tier=frontend
```

- Note: That the labels and selectors cannot have different values
```bash
$ cat replicaset-definition-1.yaml | grep -B 2 tier
  selector:
    matchLabels:
      tier: frontend
--
    metadata:
      labels:
        tier: nginx
$ kubectl apply -f replicaset-definition-1.yaml
The ReplicaSet "replicaset-1" is invalid: spec.template.metadata.labels: Invalid value: map[string]string{"tier":"nginx"}: `selector` does not match template `labels`

$ cat replicaset-definition-1.yaml | grep -B 2 tier
  selector:
    matchLabels:
      tier: frontend
--
    metadata:
      labels:
        tier: frontend

$ kubectl apply -f replicaset-definition-1.yaml
replicaset.apps/replicaset-1 created
```