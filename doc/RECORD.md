# Command Record

(Very rough!)

## User setup

```shell
openssl genrsa -out kube-liamdawson.key 2048
openssl req -new -key kube-liamdawson.key -out kube-liamdawson.csr -subj "/CN=liamdawson/"

cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: liamdawson
spec:
  signerName: kubernetes.io/kube-apiserver-client
  groups:
  - system:authenticated
  request: <base64'd kube-liamdawson.csr>
  usages:
  - client auth
EOF

kubectl certificate approve liamdawson
kubectl get csr/liamdawson -o template={{.status.certificate}} | base64 -d

kubectl create clusterrolebinding cluster-admin-liamdawson --clusterrole=cluster-admin --user=liamdawson

# on user machine
# kubectl config set-credentials cygnus-liamdawson --client-key="$HOME/.kube/credentials/cygnus-liamdawson.key" --client-certificate="$HOME/.kube/credentials/cygnus-liamdawson.crt" --embed-certs=false
# kubectl config set-cluster cygnus --server=https://kubecontrol.home.ldaws.net:6443
# kubectl config set-context cygnus --cluster=cygnus --user=cygnus-liamdawson
```

## Polaris

(First control-plane node)

```shell
sudo kubeadm init \
  --control-plane-endpoint="kubecontrol.$(hostname -d)" \
  --pod-network-cidr=10.217.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown "$(id -u):$(id -g)" "${HOME}/.kube/config"
kubectl create -f https://raw.githubusercontent.com/cilium/cilium/1.8.2/install/kubernetes/quick-install.yaml
```
