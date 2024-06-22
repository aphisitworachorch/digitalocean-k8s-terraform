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
    source      = "scripts/join-master.sh"
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


  provisioner "file" {
    source      = "k8s/digitalocean-secret.yaml"
    destination = "/tmp/digitalocean-secret.yaml"
    connection {
      type        = "ssh"
      user        = "root"
      host        = digitalocean_droplet.master-node[count.index].ipv4_address
      private_key = file("ssh_keys/id_rsa")
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sed -i -e \"s|{{access-token}}|${var.do_token}|g\" /tmp/digitalocean-secret.yaml",
    ]
    connection {
      type        = "ssh"
      user        = "root"
      host        = digitalocean_droplet.master-node[count.index].ipv4_address
      private_key = file("ssh_keys/id_rsa")
      timeout     = "600s"
    }
  }

  provisioner "file" {
    source      = "scripts/additional-setup-master-k8s.sh"
    destination = "/tmp/additional-setup-master-k8s.sh"
    connection {
      type        = "ssh"
      user        = "root"
      host        = digitalocean_droplet.master-node[count.index].ipv4_address
      private_key = file("ssh_keys/id_rsa")
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/additional-setup-master-k8s.sh",
      "sudo /tmp/additional-setup-master-k8s.sh"
    ]
    connection {
      type        = "ssh"
      user        = "root"
      host        = digitalocean_droplet.master-node[count.index].ipv4_address
      private_key = file("ssh_keys/id_rsa")
      timeout     = "600s"
    }
  }

  provisioner "file" {
    source      = "k8s/cilium-lb-ip-pool.yaml"
    destination = "/tmp/cilium-lb-ip-pool.yaml"
    connection {
      type        = "ssh"
      user        = "root"
      host        = digitalocean_droplet.master-node[count.index].ipv4_address
      private_key = file("ssh_keys/id_rsa")
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sed -i -e \"s|{{ipv4-ip}}|${digitalocean_droplet.master-node[count.index].ipv4_address}|g\" /tmp/cilium-lb-ip-pool.yaml",
      "sed -i -e \"s|{{ipv6-ip}}|${digitalocean_droplet.master-node[count.index].ipv6_address}|g\" /tmp/cilium-lb-ip-pool.yaml",
    ]
    connection {
      type        = "ssh"
      user        = "root"
      host        = digitalocean_droplet.master-node[count.index].ipv4_address
      private_key = file("ssh_keys/id_rsa")
      timeout     = "600s"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "export KUBECONFIG=/tmp/kubeconfig",
      "kubectl apply -f /tmp/cilium-lb-ip-pool.yaml"
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