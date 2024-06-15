#!/bin/bash

# Rocky Linux K8s Installation with Cilium Enabled on CRI-O
# This scripts for Master / Worker Node

dnf makecache --refresh
sudo dnf install yum-plugin-versionlock -y

sudo timedatectl set-timezone Asia/Bangkok

#2) Disable swap & add kernel settings

sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

sudo yum -y install epel-release
sudo yum -y update

sudo dnf install htop -y
#3) Add  kernel settings & Enable IP tables(CNI Prerequisites)

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv6.conf.all.forwarding=1
EOF

sudo sysctl -w net.ipv6.conf.all.forwarding=1
echo net.ipv6.conf.all.forwarding=1 >> /etc/sysctl.conf

# Swap Enable
dd if=/dev/zero of=/swapfile bs=256M count=32
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo cp /etc/fstab /etc/fstab.bak
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
sudo sysctl vm.swappiness=10
sudo sysctl vm.vfs_cache_pressure=50

sudo dnf update -y
sudo dnf install ca-certificates curl gnupg -y

# CRI-O Installation
export CNI_VERSION=v1.4.0

cat <<EOF | tee /etc/yum.repos.d/cri-o.repo
[cri-o]
name=CRI-O
baseurl=https://pkgs.k8s.io/addons:/cri-o:/prerelease:/main/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/addons:/cri-o:/prerelease:/main/rpm/repodata/repomd.xml.key
EOF

sudo dnf install -y container-selinux
    
# Install CNI Support

mkdir -p /opt/cni/bin/
curl -L -O https://github.com/containernetworking/plugins/releases/download/v1.5.0/cni-plugins-linux-amd64-v1.5.0.tgz
sudo tar Cxzvf /opt/cni/bin/ cni-plugins-linux-amd64-v1.5.0.tgz

#5) Installing kubeadm, kubelet and kubectl

# Update the apt package index and install packages needed to use the Kubernetes apt repository:

sudo dnf update
sudo dnf install -y ca-certificates curl

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl
EOF

# Update apt package index, install kubelet, kubeadm and kubectl, and pin their version:

sudo dnf update
sudo dnf install -y cri-o cri-tools

# apt-mark hold will prevent the package from being automatically upgraded or removed.

sudo dnf versionlock cri-o

# Enable and start kubelet service
sudo systemctl daemon-reload
sudo systemctl enable --now crio
sudo systemctl start crio

# Initialize Kubernetes
## This Installation without Kube Proxy
## We Use Cilium Instead of Kube-Proxy

sudo dnf install yum-plugin-versionlock -y

dnf makecache
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
sudo systemctl enable --now kubelet

sudo dnf versionlock kubelet kubeadm kubectl

sudo systemctl enable --now kubelet.service
sudo systemctl status kubelet