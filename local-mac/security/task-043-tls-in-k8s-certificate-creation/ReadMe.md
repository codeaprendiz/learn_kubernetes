

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