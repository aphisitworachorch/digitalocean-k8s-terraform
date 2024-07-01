resource "null_resource" "control-plane-node-setup" {
  depends_on = [digitalocean_droplet.control-plane-node]
  count      = length(digitalocean_droplet.control-plane-node)
  provisioner "file" {
    source      = var.container_library == "crio" ? "scripts/setup-k8s-crio.sh" : "scripts/setup-k8s-containerd.sh"
    destination = "/tmp/setup-k8s.sh"
    connection {
      type        = "ssh"
      user        = "root"
      host        = digitalocean_droplet.control-plane-node[count.index].ipv4_address
      private_key = file("ssh_keys/id_rsa")
    }
  }
}

resource "null_resource" "control-plane-node-install-k8s" {
  depends_on = [null_resource.control-plane-node-setup]
  count      = length(digitalocean_droplet.control-plane-node)
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/setup-k8s.sh",
      "sudo /tmp/setup-k8s.sh"
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

resource "null_resource" "master-node-setup" {
  depends_on = [null_resource.control-plane-node-setup, digitalocean_droplet.master-node]
  count      = length(digitalocean_droplet.master-node)
  provisioner "file" {
    source      = var.container_library == "crio" ? "scripts/setup-k8s-crio.sh" : "scripts/setup-k8s-containerd.sh"
    destination = "/tmp/setup-k8s.sh"
    connection {
      type        = "ssh"
      user        = "root"
      host        = digitalocean_droplet.master-node[count.index].ipv4_address
      private_key = file("ssh_keys/id_rsa")
    }
  }
}

resource "null_resource" "master-node-install-k8s" {
  depends_on = [null_resource.master-node-setup]
  count      = length(digitalocean_droplet.master-node)
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/setup-k8s.sh",
      "sudo /tmp/setup-k8s.sh"
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

resource "null_resource" "worker-node-setup" {
  depends_on = [null_resource.additional-setup-control-plane-node, digitalocean_droplet.worker-node]
  count      = length(digitalocean_droplet.worker-node)
  provisioner "file" {
    source      = var.container_library == "crio" ? "scripts/setup-k8s-crio.sh" : "scripts/setup-k8s-containerd.sh"
    destination = "/tmp/setup-k8s.sh"
    connection {
      type        = "ssh"
      user        = "root"
      host        = digitalocean_droplet.worker-node[count.index].ipv4_address
      private_key = file("ssh_keys/id_rsa")
    }
  }
}

resource "null_resource" "worker-node-install-k8s" {
  depends_on = [null_resource.worker-node-setup]
  count      = length(digitalocean_droplet.worker-node)

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/setup-k8s.sh",
      "sudo /tmp/setup-k8s.sh"
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