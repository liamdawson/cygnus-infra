# Command Recordt

## After First Boot

```shell
$ sudo passwd
New password:
Retype new password:
passwd: password updated successfully
$ sudo passwd "$(whoami)"
New password:
Retype new password:
passwd: password updated successfully
$ cat <<EOF | sudo tee /etc/ssh/sshd_config
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
EOF
$ sudo systemctl reload sshd
$ sudo usermod "$(whoami)" -aG docker
$ exit
...
$ kubeadm config images pull
[config/images] Pulled k8s.gcr.io/kube-apiserver:v1.18.3
[config/images] Pulled k8s.gcr.io/kube-controller-manager:v1.18.3
[config/images] Pulled k8s.gcr.io/kube-scheduler:v1.18.3
[config/images] Pulled k8s.gcr.io/kube-proxy:v1.18.3
[config/images] Pulled k8s.gcr.io/pause:3.2
[config/images] Pulled k8s.gcr.io/etcd:3.4.3-0
[config/images] Pulled k8s.gcr.io/coredns:1.6.7
```

## Bootstrap

```shell
sudo kubeadm init \
  --control-plane-endpoint="$(hostname -f)" \
  --pod-network-cidr=10.58.0.0/16
```

```shell
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml
kubectl taint nodes --all node-role.kubernetes.io/master-
```
