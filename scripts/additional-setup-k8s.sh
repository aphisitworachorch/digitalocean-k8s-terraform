if [ -z "$1" ]
then
    echo "IP Address is Empty!"
    exit 1
fi

dnf install -y wget

kubectl taint nodes --all node-role.kubernetes.io/control-plane-

export MASTER_NODE_IP=$1

# Install Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
sudo chmod 700 get_helm.sh
sudo ./get_helm.sh
sudo cp /usr/local/bin/helm /usr/bin/helm

# Add Cilium Repository
helm repo add cilium https://helm.cilium.io/

# Initialize Cilium
helm upgrade --install cilium cilium/cilium \
    --namespace kube-system \
    --create-namespace \
    --set bpf.masquerade=true \
    --set encryption.nodeEncryption=false \
    --set routingMode=tunnel \
    --set k8sServiceHost=$MASTER_NODE_IP \
    --set k8sServicePort=6443  \
    --set kubeProxyReplacement=true  \
    --set operator.replicas=1  \
    --set serviceAccounts.cilium.name=cilium  \
    --set serviceAccounts.operator.name=cilium-operator  \
    --set tunnelProtocol=geneve \
    --set hubble.enabled=true \
    --set hubble.relay.enabled=true \
    --set hubble.tls.auto.enabled=true \
    --set hubble.tls.enabled=true \
    --set hubble.tls.auto.method=helm \
    --set hubble.tls.auto.certValidityDuration=3650 \
    --set hubble.ui.enabled=true \
    --set prometheus.enabled=true \
    --set loadBalancer.acceleration=native \
    --set loadBalancer.mode=snat \
    --set operator.prometheus.enabled=true \
    --set ipv6.enabled=true \
    --set bandwidthManager.enabled=true \
    --set ipam.mode=kubernetes \
    --set ipam.operator.clusterPoolIPv4PodCIDRList="10.244.0.0/16" \
    --set ipam.operator.clusterPoolIPv6PodCIDRList="2001:db8:42:0::/96" \
    --set ipam.operator.clusterPoolIPv4MaskSize=24 \
    --set ipam.operator.clusterPoolIPv6MaskSize=112 \
    --set k8s.requireIPv4PodCIDR=true \
    --set k8s.requireIPv6PodCIDR=true \
    --set enableIPv6Masquerade=true \
    --set devices="{eth0}" \
    --set l2announcements.enabled=true \
    --set l2announcements.leaseDuration=3s \
    --set l2announcements.leaseRenewDeadline=1s \
    --set l2announcements.leaseRetryPeriod=200ms \
    --set externalIPs.enabled=true \
    --set hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,http}"


# Install DigitalOcean Volumes
kubectl apply -f /tmp/digitalocean-secret.yaml -n kube-system
export CSI_DO_VERSION=$(wget -qO - "https://api.github.com/repos/digitalocean/csi-digitalocean/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
kubectl apply -fhttps://raw.githubusercontent.com/digitalocean/csi-digitalocean/master/deploy/kubernetes/releases/csi-digitalocean-$CSI_DO_VERSION/{crds.yaml,driver.yaml,snapshot-controller.yaml}


# Add Memory Swap Control
helm repo add nri-plugins https://containers.github.io/nri-plugins
helm install nri-memory-qos nri-plugins/nri-memory-qos --set nri.patchRuntimeConfig=true --namespace kube-system

# Metrics Server
kubectl apply -f /tmp/metrics-server.yaml

# Install Cert-Manager
helm repo add jetstack https://charts.jetstack.io --force-update
helm upgrade --install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set crds.enabled=true