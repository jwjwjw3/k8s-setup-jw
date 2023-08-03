#!/usr/bin/bash 
# this script needs to be executed on the master node in root account.

# import current workers
source 0_settings.sh

parallel-scp -h $k8s_cluster_setup_pdir/k8s_cluster_setup/worker_hostnames/$worker_hostnames_filename -l root -o ~/Documents/parallelssh/tmpoutputs -e ~/Documents/parallelssh/tmperrors $k8s_cluster_setup_pdir/k8s_cluster_setup/cluster_setup_src/worker/1_install_k8s_tools.sh ~/1_install_k8s_tools.sh
