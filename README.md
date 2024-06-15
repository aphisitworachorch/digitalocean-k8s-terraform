# DigitalOcean Bare-Metal K8s ⚓🛞🐋

### Features 🌟
* CentOS-based K8s Install Script (AlmaLinux / Rocky Linux / CentOS)
* K8s v1.30
* Swap-Enabled
* NRI Memory Control
* Cilium eBPF
* DigitalOcean CSI Integrated

### Install Instruction 🏗️
1. For variables: write in *.tfavrs (* is any name) for variables (Example file in example.tfvars.ex)
2. To Run use : terraform apply -var-file='*.tfvars'
3. To Destroy use : terraform destroy -var-file='*.tfvars'

### Credits / Thanks to
* Narongchai (@kreactnative) (https://github.com/kreactnative/digitalocean-terraform-k8s-dualstack-elb/)