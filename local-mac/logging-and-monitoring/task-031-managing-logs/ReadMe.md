## Managing Logs

- Check the logs -f running pods having only one container
```bash
$ kubectl get pods
NAME       READY   STATUS    RESTARTS   AGE
webapp-1   1/1     Running   0          25s
$ kubectl logs -f webapp-1
[2021-01-13 19:51:10,730] INFO in event-simulator: USER1 logged out
[2021-01-13 19:51:11,731] INFO in event-simulator: USER3 logged out
[2021-01-13 19:51:12,733] INFO in event-simulator: USER3 logged in
[2021-01-13 19:51:13,735] INFO in event-simulator: USER3 is viewing page1
[2021-01-13 19:51:14,736] INFO in event-simulator: USER3 is viewing page1
[2021-01-13 19:51:15,738] WARNING in event-simulator: USER5 Failed to Login as the account is locked due to MANY FAILED ATTEMPTS.
[2021-01-13 19:51:15,738] INFO in event-simulator: USER4 is viewing page1
[2021-01-13 19:51:16,740] INFO in event-simulator: USER2 logged in
[2021-01-13 19:51:17,740] INFO in event-simulator: USER4 logged out
[2021-01-13 19:51:18,742] WARNING in event-simulator: USER7 Order failed as the item is OUT OF STOCK.
```

- What is a pod is having two containers, how to check the logs then
```bash
controlplane $ kubectl get pods
NAME       READY   STATUS    RESTARTS   AGE
webapp-1   1/1     Running   0          2m13s
webapp-2   2/2     Running   0          9s
controlplane $ kubectl logs -f webapp-2
error: a container name must be specified for pod webapp-2, choose one of: [simple-webapp db]
```

- You need to specify the container name i.e. `simple-webapp` or `db` in this case
```bash
controlplane $ kubectl logs -f webapp-2 simple-webapp
[2021-01-13 19:53:10,116] INFO in event-simulator: USER1 logged in
[2021-01-13 19:53:11,118] INFO in event-simulator: USER3 logged out
[2021-01-13 19:53:12,119] INFO in event-simulator: USER2 is viewing page1
[2021-01-13 19:53:13,121] INFO in event-simulator: USER1 is viewing page2
[2021-01-13 19:53:14,122] INFO in event-simulator: USER1 is viewing page1
[2021-01-13 19:53:15,124] WARNING in event-simulator: USER5 Failed to Login as the account is locked due to MANY FAILED ATTEMPTS.
[2021-01-13 19:53:15,124] INFO in event-simulator: USER1 is viewing page3
[2021-01-13 19:53:16,126] INFO in event-simulator: USER3 logged in
[2021-01-13 19:53:17,127] INFO in event-simulator: USER4 logged out
[2021-01-13 19:53:18,128] WARNING in event-simulator: USER30 Order failed as the item is OUT OF STOCK.
```