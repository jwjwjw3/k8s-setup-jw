#!/usr/bin/bash 
# this script needs to be executed on the master node in root account.

# import current workers
source 0_settings.sh

# # let worker nodes join k8s cluster
# parallel-ssh -t 3600 -h $k8s_cluster_setup_pdir/k8s_cluster_setup/worker_hostnames/$worker_hostnames_filename -o ~/Documents/parallelssh/tmpoutputs -e ~/Documents/parallelssh/tmperrors "`kubeadm token create --print-join-command` --cri-socket=unix:///var/run/cri-dockerd.sock"

# let worker nodes join k8s cluster
parallel-ssh -t 3600 -h $k8s_cluster_setup_pdir/k8s_cluster_setup/worker_hostnames/$worker_hostnames_filename -o ~/Documents/parallelssh/tmpoutputs -e ~/Documents/parallelssh/tmperrors `kubeadm token create --print-join-command`