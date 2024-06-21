resource "null_resource" "control-plane-node-initial" {
  depends_on = [null_resource.control-plane-node-install-k8s]
  count      = length(digitalocean_droplet.control-plane-node)
  provisioner "file" {
    source      = "scripts/initial-k8s-control-plane.sh"
    destination = "/tmp/initial-k8s-control-plane.sh"
    connection {
      type        = "ssh"
      user        = "root"
      host        = digitalocean_droplet.control-plane-node[count.index].ipv4_address
      private_key = file("ssh_keys/id_rsa")
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/initial-k8s-control-plane.sh",
      "sudo /tmp/initial-k8s-control-plane.sh ${digitalocean_droplet.control-plane-node[count.index].ipv4_address} ${digitalocean_droplet.control-plane-node[count.index].ipv6_address} ${var.cluster_name}"
    ]
    connection {
      type        = "ssh"
      user        = "root"
      host        = digitalocean_droplet.control-plane-node[count.index].ipv4_address
      private_key = file("ssh_keys/id_rsa")
      timeout     = "600s"
    }
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -i ssh_keys/id_rsa root@${digitalocean_droplet.control-plane-node[count.index].ipv4_address}:./join-master.sh scripts/join-master.sh"
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -i ssh_keys/id_rsa root@${digitalocean_droplet.control-plane-node[count.index].ipv4_address}:./join-worker.sh scripts/join-worker.sh"
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -i ssh_keys/id_rsa root@${digitalocean_droplet.control-plane-node[count.index].ipv4_address}:./kubeconfig config/kubeconfig"
  }
}