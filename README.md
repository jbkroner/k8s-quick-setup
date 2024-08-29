# Kubernetes Node Setup Script

This script automates the setup of a Kubernetes node on Ubuntu 22.04, including the installation of Docker, cri-dockerd, and Kubernetes components.

## Prerequisites

- A fresh Ubuntu 22.04 installation
- Sudo privileges on the target machine

## Usage

1. Clone the repository:
   ```
   git clone https://github.com/jbkroner/k8s-quick-setup.git
   cd k8s-quick-setup
   ```

2. Make the script executable:
   ```
   chmod +x setup.sh
   ```

3. Run the script with sudo privileges:
   ```
   sudo setup.sh
   ```

4. Follow the prompts in the script. You will be asked to confirm before proceeding with the installation.

5. After the script completes, you will be prompted to reboot the system. It's recommended to do so to ensure all changes take effect.

## What the Script Does

- Installs Docker
- Disables swap
- Configures cgroup drivers
- Removes containerd
- Installs cri-dockerd
- Installs Kubernetes components (kubeadm, kubelet, kubectl)
- Configures kubelet to use cri-dockerd

## Launching Nodes
(optional) Pre-load some kubernetes images with `kubeadm config images pull`

Launch essential services with `launch_service.sh`.  They may already be running.

Launch the master node with `sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --cri-socket=unix:///var/run/cri-dockerd.sock`

Generate join keys for workers: `sudo kubeadm token create --print-join-command`

## Logs

The script outputs logs to `/var/log/k8s_setup.log`. You can review this file for details about the installation process.

## Note

This script is intended for setting up a Kubernetes node on a fresh Ubuntu 22.04 installation. It may not work correctly on other Ubuntu versions or if the system has been previously modified.  I'll try to add support for new versions of Ubuntu in the future. 

## Troubleshooting

If you encounter any issues, please check the log file at `/var/log/k8s_setup.log` for more information. If the problem persists, please open an issue in this repository with the relevant log output.
