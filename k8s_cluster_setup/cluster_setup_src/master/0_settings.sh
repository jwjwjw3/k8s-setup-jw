#!/usr/bin/bash 
# this script needs to be written before each run, does not need to be executed.

# file with all worker node IPs under /k8s_cluster_setup/worker_hostnames/, this file has one ip address per line, no separators like ',' or ';' is needed.
worker_hostnames_filename="05_worker_cluster"   
k8s_cluster_setup_pdir=/media/d/eehc_1/dqgnnk8s
