#!/bin/bash


KUBERNETES_VERSION=v1.27
CRIO_VERSION=v1.28
cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/rpm/repodata/repomd.xml.key
EOF

cat <<EOF | tee /etc/yum.repos.d/cri-o.repo
[cri-o]
name=CRI-O
baseurl=https://pkgs.k8s.io/addons:/cri-o:/stable:/$CRIO_VERSION/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/addons:/cri-o:/stable:/$CRIO_VERSION/rpm/repodata/repomd.xml.key
EOF

dnf search kubectl kubeadm kubelet cri-o

dnf install -y cri-o kubelet kubeadm kubectl
systemctl enable --now crio.service kubelet

systemctl disable --now firewalld
sed -i 's/enforcing/permissive/g' /etc/selinux/config
setenforce 0
getenforce

swapon -s
swapoff -a

sed -i 's/\/dev\/mapper\/rl-swap/\#\/dev\/mapper\/rl-swap/g' /etc/fstab
systemctl daemon-reload

cat <<EOF> /etc/sysctl.d/k8s-mod.conf
net.bridge.bridge-nf-call-iptables=1
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-ip6tables=1
EOF
sysctl --system -q

cat <<EOF> /etc/modules-load.d/k8s-modules.conf
br_netfilter
overlay
EOF
modprobe br_netfilter
modprobe overlay

cat <<EOF> /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.0.10 controller1.example.com controller1
192.168.0.11 controller2.example.com controller2
192.168.0.12 controller3.example.com controller3
192.168.0.20 worker1.example.com worker1
192.168.0.30 worker2.example.com worker2
192.168.0.40 storage.example.com storage
192.168.0.200 lb.example.com
EOF

