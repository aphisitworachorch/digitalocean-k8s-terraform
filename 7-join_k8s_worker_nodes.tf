resource "null_resource" "worker-node-initial" {
  depends_on = [null_resource.worker-node-setup, null_resource.worker-node-install-k8s]
  count      = length(digitalocean_droplet.worker-node)
  provisioner "file" {
    source      = "joiner/join-worker.sh"
    destination = "/tmp/join-worker.sh"
    connection {
      type        = "ssh"
      user        = "root"
      host        = digitalocean_droplet.worker-node[count.index].ipv4_address
      private_key = file("ssh_keys/id_rsa")
    }
  }
  provisioner "file" {
    source      = "k8s/joiner.yaml"
    destination = "/tmp/worker-join.yaml"
    connection {
      type        = "ssh"
      user        = "root"
      host        = digitalocean_droplet.worker-node[count.index].ipv4_address
      private_key = file("ssh_keys/id_rsa")
    }
  }
  provisioner "file" {
    source      = "config/kubeconfig"
    destination = "/tmp/kubeconfig"
    connection {
      type        = "ssh"
      user        = "root"
      host        = digitalocean_droplet.worker-node[count.index].ipv4_address
      private_key = file("ssh_keys/id_rsa")
    }
  }
  provisioner "remote-exec" {
    inline = [
      "export KUBEADM_API_ENDPOINT=\"$(cat /tmp/join-worker.sh | awk '{print $3}')\"",
      "export KUBEADM_JOIN_CACERT=\"$(cat /tmp/join-worker.sh | awk '{print $7}')\"",
      "export KUBEADM_JOIN_TOKEN=\"$(cat /tmp/join-worker.sh | awk '{print $5}')\"",
      "sed -i -e \"s/{{control-plane-endpoint}}/$KUBEADM_API_ENDPOINT/g\" /tmp/worker-join.yaml",
      "sed -i -e \"s/{{control-plane-join-token}}/$KUBEADM_JOIN_TOKEN/g\" /tmp/worker-join.yaml",
      "sed -i -e \"s/{{control-plane-ca-cert-hash}}/$KUBEADM_JOIN_CACERT/g\" /tmp/worker-join.yaml",
      "sed -i -e \"s/{{node-ipv4}}/${digitalocean_droplet.worker-node[count.index].ipv4_address}/g\" /tmp/worker-join.yaml",
      "sed -i -e \"s/{{node-ipv6}}/${digitalocean_droplet.worker-node[count.index].ipv6_address}/g\" /tmp/worker-join.yaml",
      "kubeadm join --config=/tmp/worker-join.yaml"
    ]
    connection {
      type        = "ssh"
      user        = "root"
      host        = digitalocean_droplet.worker-node[count.index].ipv4_address
      private_key = file("ssh_keys/id_rsa")
      timeout     = "600s"
    }
  }
}