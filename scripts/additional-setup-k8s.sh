if [ -z "$1" ]
then
    echo "IP Address is Empty!"
    exit 1
fi

kubectl taint nodes --all node-role.kubernetes.io/control-plane-

export MASTER_NODE_IP=$1

# Metrics Server
kubectl apply -f /tmp/metrics-server.yaml

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
    --set bpf.autoMount.enabled=false \
    --set encryption.nodeEncryption=false \
    --set routingMode=tunnel \
    --set k8sServiceHost=$MASTER_NODE_IP \
    --set k8sServicePort=6443  \
    --set kubeProxyReplacement=true  \
    --set prometheus.enabled=true \
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
    --set hubble.metrics.enableOpenMetrics=true \
    --set hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,httpV2:exemplars=true;labelsContext=source_ip\,source_namespace\,source_workload\,destination_ip\,destination_namespace\,destination_workload\,traffic_direction}" \
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
    --set devices="{eth0, eth1}" \
    --set l2announcements.enabled=true \
    --set l2announcements.leaseDuration=3s \
    --set l2announcements.leaseRenewDeadline=1s \
    --set l2announcements.leaseRetryPeriod=200ms \
    --set externalIPs.enabled=true \
    --set containerRuntime.integration=crio

## Add Memory Swap Control
helm repo add nri-plugins https://containers.github.io/nri-plugins
helm install memory-qos nri-plugins/nri-memory-qos --namespace kube-system --set nri.patchRuntimeConfig=true