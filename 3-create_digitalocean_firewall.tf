resource "digitalocean_firewall" "web" {
  name        = "k8s-firewall"
  depends_on  = [digitalocean_droplet.master-node, digitalocean_droplet.worker-node, digitalocean_droplet.control-plane-node]
  droplet_ids = [for item in concat(digitalocean_droplet.master-node, digitalocean_droplet.worker-node, digitalocean_droplet.control-plane-node) : item.id]

  inbound_rule {
    protocol           = "tcp"
    port_range         = "2379-2380"
    source_droplet_ids = [for item in concat(digitalocean_droplet.master-node, digitalocean_droplet.worker-node, digitalocean_droplet.control-plane-node) : item.id]
  }

  inbound_rule {
    protocol           = "tcp"
    port_range         = "10250-10255"
    source_droplet_ids = [for item in concat(digitalocean_droplet.master-node, digitalocean_droplet.worker-node, digitalocean_droplet.control-plane-node) : item.id]
  }

  inbound_rule {
    protocol           = "tcp"
    port_range         = "8472"
    source_droplet_ids = [for item in concat(digitalocean_droplet.master-node, digitalocean_droplet.worker-node, digitalocean_droplet.control-plane-node) : item.id]
  }

  inbound_rule {
    protocol           = "tcp"
    port_range         = "30000-32767"
    source_droplet_ids = [for item in concat(digitalocean_droplet.master-node, digitalocean_droplet.worker-node, digitalocean_droplet.control-plane-node) : item.id]
  }

  inbound_rule {
    protocol           = "tcp"
    port_range         = "4240-4245"
    source_droplet_ids = [for item in concat(digitalocean_droplet.master-node, digitalocean_droplet.worker-node, digitalocean_droplet.control-plane-node) : item.id]
  }

  inbound_rule {
    protocol           = "tcp"
    port_range         = "6060-6062"
    source_droplet_ids = [for item in concat(digitalocean_droplet.master-node, digitalocean_droplet.worker-node, digitalocean_droplet.control-plane-node) : item.id]
  }

  inbound_rule {
    protocol           = "tcp"
    port_range         = "9879-9893"
    source_droplet_ids = [for item in concat(digitalocean_droplet.master-node, digitalocean_droplet.worker-node, digitalocean_droplet.control-plane-node) : item.id]
  }

  inbound_rule {
    protocol           = "tcp"
    port_range         = "9962-9964"
    source_droplet_ids = [for item in concat(digitalocean_droplet.master-node, digitalocean_droplet.worker-node, digitalocean_droplet.control-plane-node) : item.id]
  }

  inbound_rule {
    protocol           = "tcp"
    port_range         = "51871"
    source_droplet_ids = [for item in concat(digitalocean_droplet.master-node, digitalocean_droplet.worker-node, digitalocean_droplet.control-plane-node) : item.id]
  }

  inbound_rule {
    protocol           = "tcp"
    port_range         = "15021"
    source_droplet_ids = [for item in concat(digitalocean_droplet.master-node, digitalocean_droplet.worker-node, digitalocean_droplet.control-plane-node) : item.id]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "udp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "6443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}