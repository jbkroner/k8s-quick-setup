# Kubernetes Node Setup Script

This script automates the setup of a Kubernetes node on Ubuntu 20.04, including the installation of Docker, cri-dockerd, and Kubernetes components.

## Prerequisites

- A fresh Ubuntu 20.04 installation
- Sudo privileges on the target machine

## Usage

1. Clone the repository:
   ```
   git clone https://github.com/jbkroner/k8s-quick-setup.git
   cd k8s-quick-setup
   ```

2. Make the script executable:
   ```
   chmod +x k8s_setup.sh
   ```

3. Run the script with sudo privileges:
   ```
   sudo ./k8s_setup.sh
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

## Logs

The script outputs logs to `/var/log/k8s_setup.log`. You can review this file for details about the installation process.

## Note

This script is intended for setting up a Kubernetes node on a fresh Ubuntu 20.04 installation. It may not work correctly on other Ubuntu versions or if the system has been previously modified.  I'll try to add support for new versions of Ubuntu in the future. 

## Troubleshooting

If you encounter any issues, please check the log file at `/var/log/k8s_setup.log` for more information. If the problem persists, please open an issue in this repository with the relevant log output.
