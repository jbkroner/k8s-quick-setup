#!/bin/bash
# k8s setup script
# environment config: 
# - disable swapping
# - disable containerd
# install:
# - docker
# - kubernetes: kubeadm, kubectl, kubelet

set -e # Exit immediately if a command exits with a non-zero status.

# Logging
exec > >(tee -i /var/log/k8s_setup.log)
exec 2>&1

echo "Starting Kubernetes setup script"
# Version Check
if [[ $(lsb_release -rs) != "22.04" ]]; then
    echo "This script is intended for Ubuntu 22.04. Your version is $(lsb_release -rs). Exiting."
    exit 1
fi

# User Confirmation
read -p "This script will install Kubernetes and its dependencies. Do you want to continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

### INSTALL DOCKER
echo -e "\nk8s setup >>> Installing Docker"
if command -v docker &> /dev/null
then
    echo "Docker already installed, skipping"
else
    # Update package list and install prerequisites
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    # Add Docker repository
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

    # Install Docker
    sudo apt-get update
    sudo apt-get install -y docker-ce

    # Start and enable Docker service
    sudo systemctl start docker
    sudo systemctl enable docker

    echo "Docker installation completed and service started"
fi

### DISABLE SWAP
echo -e "\nk8s setup >>> Disabling swap"
if [ $(swapon --show | wc -l) -eq 0 ]; then
    echo "Swap is already disabled"
else
    # Disable swap
    sudo swapoff -a
    # Comment out swap line in /etc/fstab
    sudo sed -i '/swap/s/^/#/' /etc/fstab
    echo "Swap has been disabled"
fi

### CONFIGURE CGROUP DRIVERS
echo -e "\nk8s setup >>> Configuring cgroup drivers to use systemd"
# Configure Docker
echo '{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}' | sudo tee /etc/docker/daemon.json
sudo systemctl restart docker

### REMOVE CONTAINERD
echo -e "\nk8s setup >>> Removing containerd"
if command -v containerd &> /dev/null
then
    sudo systemctl stop containerd
    sudo apt-get remove --purge containerd -y
    sudo rm -rf /etc/containerd
    echo "containerd has been removed"
else
    echo "containerd is not installed, skipping removal"
fi

### INSTALL CRI-DOCKERD
echo -e "\nk8s setup >>> Installing cri-dockerd"
wget -O /tmp/cri-dockerd.deb https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.15/cri-dockerd_0.3.15.3-0.ubuntu-jammy_amd64.deb
sudo dpkg -i /tmp/cri-dockerd.deb
rm /tmp/cri-dockerd.deb
sudo systemctl enable cri-docker.service
sudo systemctl enable --now cri-docker.socket
echo "cri-dockerd installation completed"

### INSTALL KUBERNETES COMPONENTS
echo -e "\nk8s setup >>> Installing Kubernetes components"

# Create keyrings directory
sudo mkdir -p /etc/apt/keyrings

# Update package index and install packages needed for Kubernetes repository
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Download the public signing key for the Kubernetes package repositories
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add the Kubernetes apt repository
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update apt package index, install kubelet, kubeadm and kubectl, and pin their version
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Enable kubelet
sudo systemctl enable --now kubelet

echo "Kubernetes components installation completed"

### CONFIGURE KUBELET FOR CRI-DOCKERD
echo "k8s setup >>> configuring kubelet to use cri-dockerd"
sudo mkdir -p /etc/default
cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS="--container-runtime=remote --container-runtime-endpoint=unix:///var/run/cri-dockerd.sock"
EOF

# Restart kubelet to apply changes
sudo systemctl daemon-reload
sudo systemctl restart kubelet

echo "k8s setup >>> kubelet configured to use cri-dockerd"

# Cleanup
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*

echo "k8s setup >>> script completed."

# Reboot Recommendation
read -p "It's recommended to reboot the system. Would you like to reboot now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo reboot
fi