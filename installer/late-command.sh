#!/usr/bin/env sh

set -eux

echo 'kubeadmin ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/kubeadmin
sudo -u kubeadmin ssh-import-id gh:liamdawson

cat <<EOF | sudo tee /etc/apt/sources.list
deb http://ftp.au.debian.org/debian buster main contrib
deb http://security.debian.org/debian-security buster/updates main contrib
deb http://ftp.au.debian.org/debian buster-updates main contrib
EOF

# docker/kubernetes repositories
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/k8s.list

apt-get update -y

apt-get install -y \
  containerd.io=1.2.13-2 \
  docker-ce=5:19.03.11~3-0~debian-buster \
  docker-ce-cli=5:19.03.11~3-0~debian-buster \
  kubeadm \
  kubectl \
  kubelet

apt-mark hold kubelet kubeadm kubectl

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

mkdir -p /etc/systemd/system/docker.service.d
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
