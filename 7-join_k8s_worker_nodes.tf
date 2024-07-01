resource "null_resource" "push-worker-node-join" {
  depends_on = [null_resource.worker-node-setup, null_resource.worker-node-install-k8s]
  count      = length(digitalocean_droplet.worker-node)
  provisioner "file" {
    source      = "joiner/join-worker.sh"
    destination = "./join-worker.sh"
    connection {
      type        = "ssh"
      user        = "root"
      host        = digitalocean_droplet.worker-node[count.index].ipv4_address
      private_key = file("ssh_keys/id_rsa")
    }
  }
}

resource "null_resource" "join-worker-node" {
  depends_on = [null_resource.push-worker-node-join]
  count      = length(digitalocean_droplet.worker-node)

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x ./join-worker.sh",
      "sudo ./join-worker.sh"
    ]
    connection {
      type        = "ssh"
      user        = "root"
      host        = digitalocean_droplet.worker-node[count.index].ipv4_address
      private_key = file("ssh_keys/id_rsa")
      timeout     = "600s"
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
      "export KUBECONFIG=/tmp/kubeconfig",
      "kubectl label node ${var.worker_node_name}-${count.index + 1} node-role.kubernetes.io/worker=worker"
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