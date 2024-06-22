# Install DigitalOcean Volumes
kubectl apply -f /tmp/digitalocean-secret.yaml -n kube-system
export CSI_DO_VERSION=$(wget -qO - "https://api.github.com/repos/digitalocean/csi-digitalocean/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
kubectl apply -fhttps://raw.githubusercontent.com/digitalocean/csi-digitalocean/master/deploy/kubernetes/releases/csi-digitalocean-$CSI_DO_VERSION/{crds.yaml,driver.yaml,snapshot-controller.yaml}
