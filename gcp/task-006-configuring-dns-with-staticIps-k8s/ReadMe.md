# Configuring Domain Names with Static IP Addresses

[configuring-domain-name-static-ip](https://cloud.google.com/kubernetes-engine/docs/tutorials/configuring-domain-name-static-ip)

This tutorial demonstrates the following steps:

- Reserve a static external IP address for your application
- Configure either Service or Ingress resources to use the static IP
- Update DNS records of your domain name to point to your application


## Step 0:
GKE Cluster created `us-central1-c	`

![](.ReadMe_images/GKE cluster created.png)

## Step 1: 

Deploy your web application

```bash
$ kubectl apply -f helloweb-deployment.yaml
deployment.apps/helloweb created
```

## Step 2: 

Expose your application

### Use a Service
- Use a Service, which creates a TCP Network Load Balancer that works with regional IP addresses.

- To use a Service, create a static IP address named helloweb-ip in the region us-central1:

```bash
$ gcloud compute addresses create helloweb-ip --region us-central1
Created [https://www.googleapis.com/compute/v1/projects/gcloud-262311/regions/us-central1/addresses/helloweb-ip].
```
  
- To find the static IP address you created, run the following command:
 
```bash
$ gcloud compute addresses describe helloweb-ip --region us-central1
address: 34.67.51.160
addressType: EXTERNAL
creationTimestamp: '2020-04-13T15:17:53.083-07:00'
description: ''
id: '1347105937512029182'
kind: compute#address
name: helloweb-ip
networkTier: PREMIUM
region: https://www.googleapis.com/compute/v1/projects/gcloud-262311/regions/us-central1
selfLink: https://www.googleapis.com/compute/v1/projects/gcloud-262311/regions/us-central1/addresses/helloweb-ip
status: RESERVED
```

- Use the above static IP  to create a manifest file named `helloweb-service.yaml` describing a Service

- Create the service

```bash

```


