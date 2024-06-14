resource "null_resource" "copy-kubeconfig" {
    depends_on = [null_resource.join-worker-node]
    count      = length(digitalocean_droplet.control-plane-node)

    provisioner "local-exec" {
        command = "scp -o StrictHostKeyChecking=no -i ssh_keys/id_rsa root@${digitalocean_droplet.control-plane-node[count.index].ipv4_address}:~/.kube/config config/kubeconfig"
    }
}