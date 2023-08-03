#!/usr/bin/bash 
# this script needs to be executed on the master node in root account.

# import current workers
source 0_settings.sh

parallel-ssh -t 3600 -h $k8s_cluster_setup_pdir/k8s_cluster_setup/worker_hostnames/$worker_hostnames_filename -o ~/Documents/parallelssh/tmpoutputs -e ~/Documents/parallelssh/tmperrors chmod +x ~/1_install_k8s_tools.sh 
parallel-ssh -t 3600 -h $k8s_cluster_setup_pdir/k8s_cluster_setup/worker_hostnames/$worker_hostnames_filename -o ~/Documents/parallelssh/tmpoutputs -e ~/Documents/parallelssh/tmperrors bash ~/1_install_k8s_tools.sh