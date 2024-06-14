variable "do_token" {
  description = "DigitalOcean Personal Access Token"
  type        = string

  validation {
    condition     = var.do_token != null
    error_message = "DigitalOcean PAT Token must not be null!"
  }
}

variable "droplet_images" {
  description = "Droplet Images"
  type        = string
  validation {
    condition     = var.droplet_images != null
    error_message = "Node Images Can't Be Null"
  }
}

variable "master_node_name" {
  description = "Master Node Name"
  type        = string
  validation {
    condition     = var.master_node_name != null
    error_message = "Master Node Name Can't Be Null"
  }
}

variable "master_node_droplet_size" {
  description = "Master Node Droplet Size"
  type        = string
  validation {
    condition     = var.master_node_droplet_size != null
    error_message = "Master Node Droplet Size Can't Be Null"
  }
}

variable "master_nodes_count" {
  description = "Master Node Counts"
  type        = number
  validation {
    condition     = var.master_nodes_count % 2 == 0 || var.master_nodes_count == 1
    error_message = "Master Node must be even number!"
  }
}

variable "worker_node_name" {
  description = "Worker Node Name"
  type        = string
  validation {
    condition     = var.worker_node_name != null
    error_message = "Worker Node Name Can't Be Null"
  }
}

variable "worker_node_droplet_size" {
  description = "Worker Node Droplet Size"
  type        = string
  validation {
    condition     = var.worker_node_droplet_size != null
    error_message = "Worker Node Droplet Size Can't Be Null"
  }
}

variable "worker_nodes_count" {
  description = "Worker Node Counts"
  type        = number
  validation {
    condition     = var.worker_nodes_count % 2 != 0 || var.worker_nodes_count == 1
    error_message = "Worker Node must be odd number!"
  }
}

variable "digitalocean_tags" {
  description = "DigitalOcean Droplet Tags"
  type        = list(string)
}

variable "digitalocean_vpc" {
  description = "DigitalOcean VPC"
  type        = string
}

variable "digitalocean_ssh_list" {
  description = "DigitalOcean SSH List"
  type        = list(string)
}

variable "digitalocean_region" {
  description = "DigitalOcean Region"
  type        = string
}

variable "cluster_name" {
  description = "Cluster Name"
  type        = string
  validation {
    condition     = var.cluster_name != null
    error_message = "Cluster Name Shouldn't be Null"
  }
}

variable "control_plane_node_name" {
  description = "Control Plane Node Name"
  type        = string
  validation {
    condition     = var.control_plane_node_name != null
    error_message = "Control Plane Node Name Shouldn't be Null"
  }
}

variable "control_plane_node_droplet_size" {
  description = "Control Plane Node Droplet Size"
  type        = string
  validation {
    condition     = var.control_plane_node_droplet_size != null
    error_message = "Control Plane Node Droplet Size Can't Be Null"
  }
}