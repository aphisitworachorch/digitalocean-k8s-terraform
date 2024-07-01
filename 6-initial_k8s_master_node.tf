resource "null_resource" "master-node-initial" {
  depends_on = [null_resource.additional-setup-control-plane-node, null_resource.master-node-install-k8s]
  count      = length(digitalocean_droplet.master-node)
  provisioner "file" {
    source      = "config/kubeconfig"
    destination = "/tmp/kubeconfig"
    connection {
      type        = "ssh"
      user        = "root"
      host        = digitalocean_droplet.master-node[count.index].ipv4_address
      private_key = file("ssh_keys/id_rsa")
    }
  }

  provisioner "file" {
    source      = "joiner/join-master.sh"
    destination = "/tmp/join-master.sh"
    connection {
      type        = "ssh"
      user        = "root"
      host        = digitalocean_droplet.master-node[count.index].ipv4_address
      private_key = file("ssh_keys/id_rsa")
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/join-master.sh",
      "sudo /tmp/join-master.sh"
    ]
    connection {
      type        = "ssh"
      user        = "root"
      host        = digitalocean_droplet.master-node[count.index].ipv4_address
      private_key = file("ssh_keys/id_rsa")
      timeout     = "600s"
    }
  }
}