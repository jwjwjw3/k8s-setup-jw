#!/usr/bin/bash 
# this script needs to be executed on the master node in root account.

# import current workers
source 0_settings.sh

# reset k8s cluster from master node
sudo kubeadm reset -f

# delete k8s setup on master node
rm -rf $HOME/.kube

# delete CNI configurations on master node
sudo rm -rf /etc/cni/net.d

# reset kubeadm on all worker nodes
parallel-ssh -t 600 -h $k8s_cluster_setup_pdir/k8s_cluster_setup/worker_hostnames/$worker_hostnames_filename -o ~/Documents/parallelssh/tmpoutputs -e ~/Documents/parallelssh/tmperrors kubeadm reset -f --cri-socket=unix:///var/run/cri-dockerd.sock

# # reset kubeadm on all worker nodes
# parallel-ssh -t 600 -h $k8s_cluster_setup_pdir/k8s_cluster_setup/worker_hostnames/$worker_hostnames_filename -o ~/Documents/parallelssh/tmpoutputs -e ~/Documents/parallelssh/tmperrors kubeadm reset -f 

# delete k8s setup on all worker nodes
parallel-ssh -t 300 -h $k8s_cluster_setup_pdir/k8s_cluster_setup/worker_hostnames/$worker_hostnames_filename -o ~/Documents/parallelssh/tmpoutputs -e ~/Documents/parallelssh/tmperrors rm -rf $HOME/.kube

# delete k8s setup on all worker nodes
parallel-ssh -t 300 -h $k8s_cluster_setup_pdir/k8s_cluster_setup/worker_hostnames/$worker_hostnames_filename -o ~/Documents/parallelssh/tmpoutputs -e ~/Documents/parallelssh/tmperrors sudo rm -rf /etc/cni/net.d