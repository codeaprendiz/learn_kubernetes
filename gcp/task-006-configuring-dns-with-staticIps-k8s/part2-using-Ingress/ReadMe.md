# Configuring Domain Names with Static IP Addresses

[configuring-domain-name-static-ip](https://cloud.google.com/kubernetes-engine/docs/tutorials/configuring-domain-name-static-ip)

This tutorial demonstrates the following steps:

- Reserve a static external IP address for your application
- Configure either Service or Ingress resources to use the static IP
- Update DNS records of your domain name to point to your application


## Step 0:
GKE Cluster created `us-central1-c	`

![](../part1-using-Service/.ReadMe_images/GKE cluster created.png)

## Step 1: 

Deploy your web application

```bash
$ kubectl apply -f helloweb-deployment.yaml
deployment.apps/helloweb created
```

## Step 2: 

Expose your application

### Using an Ingress
- If you choose to expose your application using an Ingress, 
which creates an HTTP(S) Load Balancer, you must reserve a global static IP address. Regional IP addresses do not work with Ingress.

- To create a global static IP address named helloweb-ip:
  

```bash
$ gcloud compute addresses create helloweb-ip --global
Created [https://www.googleapis.com/compute/v1/projects/gcloud-262311/global/addresses/helloweb-ip].
```
  
- To find the static IP address you created, run the following command:
 
```bash
$ gcloud compute addresses describe helloweb-ip --global
address: 35.190.35.174
addressType: EXTERNAL
creationTimestamp: '2020-04-13T15:52:30.054-07:00'
description: ''
id: '4058631783476450241'
ipVersion: IPV4
kind: compute#address
name: helloweb-ip
networkTier: PREMIUM
selfLink: https://www.googleapis.com/compute/v1/projects/gcloud-262311/global/addresses/helloweb-ip
status: RESERVED
```

- To expose a web application on a static IP using Ingress, you need to deploy two resources:
    - A Service with type:NodePort
    - An Ingress configured with the service name and static IP annotation

- Use the above static IP to create a manifest file named `helloweb-ingress.yaml` describing these two resources:
  

- Apply the helloweb-ingress.yaml manifest file to the cluster:
  

```bash
$ kubectl apply -f helloweb-ingress.yaml
ingress.extensions/helloweb created
service/helloweb-backend created
```

- To see the reserve IP address associated with the load balancer:
  
```bash
$ kubectl get ingress
NAME       HOSTS   ADDRESS         PORTS   AGE
helloweb   *       35.190.35.174   80      49s
```

### Step 3: 

Visit your reserved static IP address

```bash
$ curl http://35.190.35.174
Hello, world!
Version: 1.0.0
Hostname: helloweb-7f7f7474fc-ghncd
```

### Step 4:

Configure your domain name records
```bash
$ nslookup testservicek8s.gotdns.ch                       
Server:         192.168.1.1
Address:        192.168.1.1#53

Non-authoritative answer:
Name:   testservicek8s.gotdns.ch
Address: 34.67.51.160
```

### Step 5:
Visit the domain

```bash
$ curl http://testservicek8s.gotdns.ch                       
Hello, world!
Version: 1.0.0
Hostname: helloweb-7f7f7474fc-ghncd
```

## Cleaning up

- Delete the load balancing resources:
  
```bash
$ kubectl delete ingress,service -l app=hello
service "helloweb" deleted
```

- Release the reserved static IP

```bash
$ gcloud compute addresses delete helloweb-ip --global
The following global addresses will be deleted:
 - [helloweb-ip]

Do you want to continue (Y/n)?  Y

Deleted [https://www.googleapis.com/compute/v1/projects/gcloud-262311/global/addresses/helloweb-ip].
```

- Delete the sample application:
  
```bash
$ kubectl delete -f helloweb-deployment.yaml
deployment.apps "helloweb" deleted
```