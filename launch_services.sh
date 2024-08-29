#!/bin/bash
# launch essential services
sudo systemctl start docker 
sudo systemctl enable docker
sudo systemctl status docker

sudo systemctl start cri-docker.service
sudo systemctl enable cri-docker.service 
sudo systemctl status cri-docker.service

sudo systemctl start kubelet 
sudo systemctl enable kubelet
sudo systemctl status kubelet

sudo systemctl is-active docker cri-docker.service kubelet
