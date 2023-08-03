#!/usr/bin/bash 

################################################################################
# from https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/

# Forwarding IPv4 and letting iptables see bridged traffic 
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

# load kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# disable firewall
# sudo ufw disable

# Install basic network tools:
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl containerd ipset

# # Install docker
# for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg -y; done
# sudo apt-get update
# sudo apt-get install ca-certificates curl gnupg -y
# sudo install -m 0755 -d /etc/apt/keyrings
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
# sudo chmod a+r /etc/apt/keyrings/docker.gpg
# echo \
#   "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
#   "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
#   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# sudo apt-get update
# sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
# sudo docker run hello-world

# # Install docker-crd
# sudo apt install golang make -y
# cd ~
# git clone https://github.com/Mirantis/cri-dockerd.git
# cd ~/cri-dockerd
# make cri-dockerd
# mkdir -p /usr/local/bin
# install -o root -g root -m 0755 cri-dockerd /usr/local/bin/cri-dockerd
# install packaging/systemd/* /etc/systemd/system
# sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
# systemctl daemon-reload
# systemctl enable cri-docker.service
# systemctl enable --now cri-docker.socket

# Install kubeadm, kubelet, kubectl, need "--batch --yes" for remote script gpg signing, may need curl "-kfsSL" to solve sign issues (not a secure fix):
# curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor --batch --yes -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
curl -kfsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor --batch --yes -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update && sudo apt-get install -y kubelet=1.25.11-00 kubeadm=1.25.11-00 kubectl=1.25.11-00
sudo apt-mark hold kubelet kubeadm kubectl


# configure containerd to use containerd to use the systemdCgroup driver via config file # this solve a problem that cgroupv2 introduced with Ubuntu 21.04 and above(Debian since version 11) causes containerd and kubelet to fail.
# more details at https://stackoverflow.com/questions/55571566/unable-to-bring-up-kubernetes-api-server
# required on IBM Cloud VMs, but not required on VirtualBox VMs on Win10.
sudo mkdir /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml  
service containerd restart
service kubelet restart 