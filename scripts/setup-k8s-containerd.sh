#!/bin/bash

# CentOS-based Linux K8s Installation with Cilium Enabled on ContainerD
# This scripts for Master / Worker Node

sudo mkdir -p /etc/systemd/system/user@.service.d
cat <<EOF | sudo tee /etc/systemd/system/user@.service.d/delegate.conf
[Service]
Delegate=cpu cpuset io memory pids
EOF
sudo systemctl daemon-reload

dnf makecache --refresh
sudo dnf install yum-plugin-versionlock -y
sudo dnf install -y wget

sudo timedatectl set-timezone Asia/Bangkok

#2) Disable swap & add kernel settings

sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

sudo yum -y install epel-release
sudo yum -y update

sudo dnf install htop -y
#3) Add  kernel settings & Enable IP tables(CNI Prerequisites)

sudo modprobe overlay
sudo modprobe br_netfilter

cat > sudo tee /etc/modules-load.d/k8s.conf << EOF
overlay
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/kubernetes.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv6.conf.all.forwarding=1
EOF

sudo sysctl --system

# Enable Swap
sudo dd if=/dev/zero of=/swapfile bs=1G count=16
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo cp /etc/fstab /etc/fstab.bak
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
sudo sysctl vm.swappiness=100
sudo sysctl vm.vfs_cache_pressure=70
echo 'vm.swappiness=100' | sudo tee -a /etc/sysctl.conf
echo 'vm.vfs_cache_pressure=70' | sudo tee -a /etc/sysctl.conf

sudo dnf update -y
sudo dnf install ca-certificates curl gnupg -y
    
# Install CNI Support
export CNI_VERSION=$(wget -qO - "https://api.github.com/repos/containernetworking/plugins/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
mkdir -p /opt/cni/bin/
curl -L -O https://github.com/containernetworking/plugins/releases/download/$CNI_VERSION/cni-plugins-linux-amd64-$CNI_VERSION.tgz
sudo tar Cxzvf /opt/cni/bin/ cni-plugins-linux-amd64-$CNI_VERSION.tgz

#5) Installing kubeadm, kubelet and kubectl

# Update the apt package index and install packages needed to use the Kubernetes apt repository:

sudo dnf update
sudo dnf install -y ca-certificates curl

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl
EOF

# Update apt package index, install kubelet, kubeadm and kubectl, and pin their version:
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf update
sudo dnf install -y containerd.io
sudo mv /etc/containerd/config.toml /etc/containerd/config.toml.orig
sudo containerd config default > /etc/containerd/config.toml
sudo sed -i '/\[plugins\."io\.containerd\.nri\.v1\.nri"\]/,/^$/ s/disable = true/disable = false/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable --now containerd

# Initialize Kubernetes
## This Installation without Kube Proxy
## We Use Cilium Instead of Kube-Proxy

sudo dnf install yum-plugin-versionlock -y

dnf makecache
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
sudo dnf versionlock kubelet kubeadm kubectl
sudo systemctl enable --now kubelet
sudo systemctl enable --now kubelet.service