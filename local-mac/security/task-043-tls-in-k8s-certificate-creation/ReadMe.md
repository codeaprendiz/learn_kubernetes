

### Creating CA Certificate

Create a private key 

```bash
$ openssl genrsa -out ca.key 2048
Generating RSA private key, 2048 bit long modulus
.............................................+++
...............+++
e is 65537 (0x10001)
```

Certificate Signing Request

```bash
$ openssl req -new -key ca.key -subj "/CN=KUBERNETES-CA" -out ca.csr
```

Sign the certificate 

```bash
$ openssl x509 -req -in ca.csr -signkey ca.key -out ca.crt                                             
Signature ok
subject=/CN=KUBERNETES-CA
Getting Private key
```

Going forward we will use this ca-key pair to sign the certificates

### Generating the client certificates


Generate Keys for ADMIN USER

```bash
$ openssl genrsa -out admin.key 2048
Generating RSA private key, 2048 bit long modulus
............+++
............+++
e is 65537 (0x10001)
```

Create a certificate Signing request

```bash
$ openssl req -new -key admin.key -subj "/CN=kube-admin/O=system:masters" -out admin.csr
```

Sign the certificate using CA ca.crt and key ca.key

```bash
$ openssl x509 -req -in admin.csr -CA ca.crt -CAkey ca.key -out admin.crt
```

### How to use these certificates in API calls

```bash
curl https://kube-apiserver:6443/api/v1/pods \
  --key admin.key \
  --cert admin.crt \
  --cacert ca.crt
```
and by using `kubeconfig.yaml`

```yaml
- cluster:
    certificate-authority: ca.crt
    server: https://kube-apiserver:6443

users:
- name: kubernetes-admin
  user:
    client-certificate: admin.crt
    client-key: admin.key
```

### certs for etcd server

- Arguments while starting the etcd server

```bash
- etcd
  - --key-file=/path-to-certs/etcdserver.key
  - --cert-file=/path-to-certs/etcdserver.crt
  - --peer-cert-file=/path-to-certs/etcdpeer1.crt
  - --peer-client-cert-auth=true
  - --peer-key-file=/etc/kubernetes/pki/etcd/peer.key
  - --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
  - --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
```

### certs for KUBE API SERVER

- Generate private key
```bash
$ openssl genrsa -out apiserver.key 2048
```

- Create `openssl.cnf`

```cnf
[req]
req_extensions = v3_req
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation
subjectAltName = @alt_names
[alt_names]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster.local
IP.1 = 10.96.0.1
IP.2 = 172.17.0.87
```

- Create certificate signing request
```bash
$ openssl req --new-key apiserver.key -sub \
  "/CN=kube-apiserver" -out apiserver.csr -cofnig openss.cnf
```

- Sign the certificate 

```bash
$ openssl x509 -req -in apiserver.csr -CA ca.crt -CAkey ca.key -out apiserver.crt
```

- While starting the kuber-api-server we need to pass these as arguments

```bash
ExecStart=/sr/local/bin/kube-apiserver \\
  --etcd-cafile=/var/lib/kubernetes/ca.pem \\
  --etcd-certfile=/var/lib/kubernetes/apiserver-etcd-client.crt \\
  --etcd-keyfile=/var/lib/kubernetes/apiserver-etcd-client.key \\
  --kubelet-certificate-authority=/var/lib/kubernetes/ca.pem \\
  --kubelet-client-certificate=/car/lib/kubernetes/apiserver-etcd-client.key \\
  --kubelet-client-key=/var/lib/kubernetes/apiserver-etcd-client.key \\
  --client-ca-file=/var/lib/kubernetes/ca.pem \\
  --tls-cert-file=/var/lib/kubernetes/apiserver.crt \\
  --tls-private-key-file=/var/lib/kubernetes/apiserver.key 
```

### certs for kubelet

- Generate these certificates for eary node running a kubelet with the nodename

kubelet-config.yaml(node01)
```bash
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentiation:
 x509:
    clientCAFile: "/var/lib/kubernetes/ca.pem"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "10.32.0.10"
podCIDR: "${POD_CIDR}"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
tlsCertFile: "/var/lib/kubelet/kubelet-nod01.crt"
tlsPrivateKeyFile: "/var/lib/kubelet/kubelet-node01.key"
```


### Viewing the certificates

- Get the deployment file for example, `/etc/kubernetes/manifests/kube-apiserver.yaml` and identify the cert 
  locations

- For example, check the following certificate you can do the following

```bash
 openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout
```

- Incase you run into issues, you can check the logs by the following

```bash
$ journalctl -u etcd.service -l 

$ kubectl logs -f <pod_name> -n <namespace>

$ docker logs -f <container_name> 
```


### Identify the certificate file used for the kube-api server

```bash
controlplane $ kubectl get pods -n kube-system | grep api
kube-apiserver-controlplane               1/1     Running            0          28m

controlplane $ kubectl get pod kube-apiserver-controlplane -n kube-system -o yaml | egrep "*.crt"
    - --client-ca-file=/etc/kubernetes/pki/ca.crt
    - --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt
    - --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt
    - --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt
    - --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt
    - --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt
    - --tls-cert-file=/etc/kubernetes/pki/apiserver.crt
```

### Identify the Certificate file used to authenticate kube-apiserver as a client to ETCD Server
    
```bash
    - --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt
```

### Identify the key used to authenticate kubeapi-server to the kubelet server
    
```bash
controlplane $ kubectl get pod kube-apiserver-controlplane -n kube-system -o yaml | egrep "*.key"
    - --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key
    - --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key
    - --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client.key
    - --service-account-key-file=/etc/kubernetes/pki/sa.pub
    - --tls-private-key-file=/etc/kubernetes/pki/apiserver.key
```

### Identify the ETCD Server Certificate used to host ETCD server
    
```bash
controlplane $ kubectl get pods -n kube-system | grep etcdetcd-controlplane                          1/1     Running   0          9m27s
controlplane $ kubectl get pod etcd-controlplane -n kube-system -o yaml | egrep -i "*.crt"
    - --cert-file=/etc/kubernetes/pki/etcd/server.crt
    - --peer-cert-file=/etc/kubernetes/pki/etcd/peer.crt
    - --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
    - --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
```


### Identify the ETCD Server CA Root Certificate used to serve ETCD Server

- ETCD can have its own CA. So this may be a different CA certificate than the one used by kube-api server.

```bash
## its 
/etc/kubernetes/pki/etcd/ca.crt
```

### What is the Common Name (CN) configured on the Kube API Server Certificate?

- OpenSSL Syntax: openssl x509 -in file-path.crt -text -noout


```bash
controlplane $ kubectl describe pod kube-apiserver-controlplane -n kube-system | egrep -i "*.crt"
      --client-ca-file=/etc/kubernetes/pki/ca.crt
      --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt
      --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt
      --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt
      --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt
      --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt
      --tls-cert-file=/etc/kubernetes/pki/apiserver.crt

controlplane $ openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text --noout | egrep -i "CN"
        Issuer: CN = kubernetes
        Subject: CN = kube-apiserver
```


### What is the name of the CA who issued the Kube API Server Certificate?

```bash
## its
        Issuer: CN = kubernetes
```

### Which of the below alternate names is not configured on the Kube API Server Certificate?

```bash
$ openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text --noout | egrep -i "DNS"
                DNS:controlplane, DNS:kubernetes, DNS:kubernetes.default, DNS:kubernetes.default.svc, DNS:kubernetes.default.svc.cluster.local, IP Address:10.96.0.1, IP Address:172.17.0.27
```


### What is the Common Name (CN) configured on the ETCD Server certificate?

```bash
controlplane $ kubectl get pod etcd-controlplane -n kube-system -o yaml | grep -i "crt"
    - --cert-file=/etc/kubernetes/pki/etcd/server.crt
    - --peer-cert-file=/etc/kubernetes/pki/etcd/peer.crt
    - --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
    - --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt

controlplane $ openssl x509 -in /etc/kubernetes/pki/etcd/server.crt -text --noout | egrep -i "CN"
        Issuer: CN = etcd-ca
        Subject: CN = controlplane
```

### How long, from the issued date, is the Kube-API Server Certificate valid for?

File: /etc/kubernetes/pki/apiserver.crt

```bash
controlplane $ openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text --noout  | egrep -i "NOT"
            Not Before: Jan 30 09:04:49 2021 GMT
            Not After : Jan 30 09:04:49 2022 GMT
```

### How long, from the issued date, is the Root CA Certificate valid for?

File: /etc/kubernetes/pki/ca.crt

```bash
controlplane $ openssl x509 -in /etc/kubernetes/pki/ca.crt -text --noout  | egrep -i "NOT"
            Not Before: Jan 30 09:04:49 2021 GMT
            Not After : Jan 28 09:04:49 2031 GMT
```

### Kubectl suddenly stops responding to your commands. Check it out! Someone recently modified the /etc/kubernetes/manifests/etcd.yaml file

You are asked to investigate and fix the issue. Once you fix the issue wait for sometime for kubectl to respond. Check the logs of the ETCD container.

```bash
## Check the cert file is having below opiton
controlplane $ cat /etc/kubernetes/manifests/etcd.yaml | grep cert
    - --cert-file=/etc/kubernetes/pki/etcd/server.crt

## Check logs

controlplane $ docker logs -f k8s_etcd_etcd-controlplane_kube-system_a6d273411deec559d52163e61928b63e_0
.
.
nt:1 size:518" took too long (395.546629ms) to execute
2021-01-30 10:49:40.480447 W | etcdserver: read-only range request "key:\"/registry/services/endpoints/kube-system/cloud-controller-manager\" " with result "range_response_count:1 size:626" took too long (196.597061ms) to execute
```

### The kube-api server stopped again! Check it out. Inspect the kube-api server logs and identify the root cause and fix the issue.
 
- Run docker ps -a command to identify the kube-api server container. Run docker logs container-id command to view the logs.
   
    
```bash
controlplane $ docker logs -f k8s_kube-apiserver_kube-apiserver-controlplane_kube-system_6472c8cdb57b631c61693d0a2df0d944_3 | grep error
.
W0130 10:52:02.687657       1 clientconn.go:1208] grpc: addrConn.createTransport failed to connect to {https://127.0.0.1:2379  <nil> 0 <nil>}. Err :connection error: desc = "transport: authentication handshake failed: x509: certificate signed by unknown authority". Reconnecting...

controlplane $ vi /etc/kubernetes/manifests/kube-apiserver.yaml

controlplane $ docker logs -f k8s_kube-apiserver_kube-apiserver-controlplane_kube-system_aa4b5e1d17048721a528774f043c48b2_1
.
.
I0130 11:02:49.916463       1 controller.go:130] OpenAPI AggregationController: action for item : Nothing (removed from the queue).
I0130 11:02:49.916490       1 controller.go:130] OpenAPI AggregationController: action for item k8s_internal_local_delegation_chain_0000000000: Nothing (removed from the queue).
I0130 11:02:49.943997       1 storage_scheduling.go:143] all system priority classes are created successfully or already exist.
```

### What is a CA Server or CA

The CA is generally a pair of key and certificate file generated.

Whoever gains access to these files can sign any certificate for the kubernetes environment.
They can create as many users they want, with whatever priviledge's they want.

So these files need to be protected in a safe environment. The server where these
certificate files are stored is called as CA Server (Usually the master node)


Kubernetes has certificate API using which you can send request to kubernetes to sign the certificates.
  
**How does this happen**

A user first creates a key

```bash
$ openssl genrsa -out jane.key 2048
```

Generate the CSR using hte key with the name of the user on the same


```bash
$ openssl req -new -key jane.key -subj "/CN=jane" -out jane.csr
```


Get the base64 of the csr

```bash
$ cat jane.csr | base64              
LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ1ZEQ0NBVHdDQVFBd0R6RU5NQXNHQTFVRUF3d0VhbUZ1WlRDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRApnZ0VQQURDQ0FRb0NnZ0VCQU12UWd1bWZuS0p6QmFSaDNZejg1Vlo2Ulk3eUd3YkFlMDFJOE83bkRIcEhub3ZQClM0WXM1S3NxbFlEcVNxVmRrM0Y3ODh1dlJhWGp4T3czQ3Z6d09hbUwvdyt6OHcvM3hpRGVkb3JSR1JmRTQ3enQKOS9mcXhUNWNwRXROWkRzWjNRVGtXclV2U1ZtYXFZczJMUHl4SHJCKzRvbEdDUkhpb253ajRnckFWdEo2NkZKdAprTUNDblg0R2pxT05VSXR2dk1Iak1Id3NPeFhTc2hHL1htUXZRZUc3eVlhUGxoY1U5WHVXaWduSjRlOVkyTDU1CjBXSUgxY2JRRFdVOHRMTzRpVlRsbkZ0WGdmbUJUdjhUTVkyNUF4blJwS2FudVgxY29Rc3JWdk9LcDlIdWVVUWoKVnFXV1hmTlRNeW9OL1JRNy9RYnBIdWhEUUVoWjZtNG9YMzBuUENrQ0F3RUFBYUFBTUEwR0NTcUdTSWIzRFFFQgpDd1VBQTRJQkFRQVE4dThmbHhta0xNaFNvNUFsbjhjRlVtQWRqZ2VTM2FuZEZlWXJmOHRsQ0lpYUFFMDJrN2NiCnF5TUdNMkZ6MmVpZ21mbEo0MmtMTkhTVDB6VG8xMlRwRzE1TFV1VzljMUZiTkhhZ0VhZzVDUFZqdzk0UllnVTcKcGhvMm1vbFUzNGJ3Sko5MEVaUVA0b0Q1U0pNN1VkZmh0dXVXUER1OEgyZHJmVXVIYUtqK1J4c1ZMVy9La1pzWAo3ZVlPTnZOcU1VMVBrY0lCRWgwTjJIdUZtaWVYREpEV3grdmhWYlQ1eHNwNVI3SUlodnhQTG92Q1ZOYldqWllLCnQ2UE96eDdWL0V6Qm02STlmUDhHOU9KbmNQYTlaZXZhdUpmRnl3cXhJUEhZb3ZEMkMxOXhvNEtTSkx1VFdld2UKUXNUSWpXWkdpZnV6VDVUN1NZazlCMVYzb3lUcDk1c0kKLS0tLS1FTkQgQ0VSVElGSUNBVEUgUkVRVUVTVC0tLS0tCg==
```


Now create CertificateSigningRequest object

```yaml
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: jane
spec:
 groups:
 - system:authenticated
 usages:
   - digital signature
   - key encipherment
   - server auth
 request: 
    LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ1ZEQ0NBVHdDQVFBd0R6RU5NQXNHQTFVRUF3d0VhbUZ1WlRDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRApnZ0VQQURDQ0FRb0NnZ0VCQU12UWd1bWZuS0p6QmFSaDNZejg1Vlo2Ulk3eUd3YkFlMDFJOE83bkRIcEhub3ZQClM0WXM1S3NxbFlEcVNxVmRrM0Y3ODh1dlJhWGp4T3czQ3Z6d09hbUwvdyt6OHcvM3hpRGVkb3JSR1JmRTQ3enQKOS9mcXhUNWNwRXROWkRzWjNRVGtXclV2U1ZtYXFZczJMUHl4SHJCKzRvbEdDUkhpb253ajRnckFWdEo2NkZKdAprTUNDblg0R2pxT05VSXR2dk1Iak1Id3NPeFhTc2hHL1htUXZRZUc3eVlhUGxoY1U5WHVXaWduSjRlOVkyTDU1CjBXSUgxY2JRRFdVOHRMTzRpVlRsbkZ0WGdmbUJUdjhUTVkyNUF4blJwS2FudVgxY29Rc3JWdk9LcDlIdWVVUWoKVnFXV1hmTlRNeW9OL1JRNy9RYnBIdWhEUUVoWjZtNG9YMzBuUENrQ0F3RUFBYUFBTUEwR0NTcUdTSWIzRFFFQgpDd1VBQTRJQkFRQVE4dThmbHhta0xNaFNvNUFsbjhjRlVtQWRqZ2VTM2FuZEZlWXJmOHRsQ0lpYUFFMDJrN2NiCnF5TUdNMkZ6MmVpZ21mbEo0MmtMTkhTVDB6VG8xMlRwRzE1TFV1VzljMUZiTkhhZ0VhZzVDUFZqdzk0UllnVTcKcGhvMm1vbFUzNGJ3Sko5MEVaUVA0b0Q1U0pNN1VkZmh0dXVXUER1OEgyZHJmVXVIYUtqK1J4c1ZMVy9La1pzWAo3ZVlPTnZOcU1VMVBrY0lCRWgwTjJIdUZtaWVYREpEV3grdmhWYlQ1eHNwNVI3SUlodnhQTG92Q1ZOYldqWllLCnQ2UE96eDdWL0V6Qm02STlmUDhHOU9KbmNQYTlaZXZhdUpmRnl3cXhJUEhZb3ZEMkMxOXhvNEtTSkx1VFdld2UKUXNUSWpXWkdpZnV6VDVUN1NZazlCMVYzb3lUcDk1c0kKLS0tLS1FTkQgQ0VSVElGSUNBVEUgUkVRVUVTVC0tLS0tCg==
```

Now you can submit this request. Once the object is created all admins can view the request using


```bash
kubectl get csr
NAME   AGE    REQUESTOR             CONDITION
jane   10m     admin@example.com    Pending
```

Any admin can approve the request by using the following command

```bash
kubectl certificate approve jane
```

Now you can view the ceritificate using

```bash
kubectl get csr jane -o yaml
```

Now you will again need to decode the certificate using `base64 --decode`

```bash
echo "encoded - certificate" | base64 --decode 
```


NOTE: The certificate related operations are carried by the controller-manager 