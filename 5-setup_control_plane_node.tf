resource "null_resource" "additional-setup-control-plane-node" {
  depends_on = [null_resource.control-plane-node-initial]
  count      = length(digitalocean_droplet.control-plane-node)

  provisioner "file" {
    source      = "k8s/metrics-server.yaml"
    destination = "/tmp/metrics-server.yaml"
    connection {
      type        = "ssh"
      user        = "root"
      host        = digitalocean_droplet.control-plane-node[count.index].ipv4_address
      private_key = file("ssh_keys/id_rsa")
    }
  }

  provisioner "file" {
    source      = var.container_library == "crio" ? "scripts/additional-setup-k8s-crio.sh" : "scripts/additional-setup-k8s-containerd.sh"
    destination = "/tmp/additional-setup-k8s.sh"
    connection {
      type        = "ssh"
      user        = "root"
      host        = digitalocean_droplet.control-plane-node[count.index].ipv4_address
      private_key = file("ssh_keys/id_rsa")
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/additional-setup-k8s.sh",
      "sudo /tmp/additional-setup-k8s.sh ${digitalocean_droplet.control-plane-node[count.index].ipv4_address} ${digitalocean_droplet.control-plane-node[count.index].ipv6_address}"
    ]
    connection {
      type        = "ssh"
      user        = "root"
      host        = digitalocean_droplet.control-plane-node[count.index].ipv4_address
      private_key = file("ssh_keys/id_rsa")
      timeout     = "600s"
    }
  }
}