# Installation Guide

## Overview

This repo contains several bash scripts used to install a k8s cluster with a 1-master N-worker setup and installs Kepler(https://github.com/sustainable-computing-io/kepler) and Kube-Prometheus (https://github.com/prometheus-operator/kube-prometheus). User needs to run bash scripts one-by-one in a specified order on the machine that becomes k8s master node, and manually check outputs of each bash script, and rerun if some script fails. 

## Requirements
- Root access for master node and all worker nodes are required. (In principle some scripts should work with non-root user running sudo, but that is not tested) 
- The master node machine should be able to ping all the worker node machines and use SSH to login to each of them.
- Internet access of master node machine and all worker node machines are needed.
- All worker node machines are accessed from master node machine using the same SSH key, user should put ssh key files under directory:
    ```
    /k8s_cluster_setup/cluster_setup_src/ssh_credentials
    ```

## K8s tools used under directory ```/k8s_cluster_setup/k8s_tools```
- Flannel
    - Downloaded from https://github.com/flannel-io/flannel/releases/download/v0.22.1/kube-flannel.yml

<!-- - Calico
    - Downloaded using command:
    ```
    curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml -O
    ``` -->
- Kepler
    - Kepler, Git branch release-0.5.3
    - build with command: 
        ```
        cd /k8s_cluster_setup/k8s_tools/kepler
        make build-manifest OPTS="PROMETHEUS_DEPLOY"
        ```
- Kube-Prometheus
    - Kube-Prometheus, Git branch release-0.12

Also tried Calico as pod network plugin, but unfortunately default calico setting doesn't work and pod on different machines cannot communicate on a VM-based cluster on IBM Cloud.

## Scripts behavior description

All scripts the user needs to run are in:
```
/k8s_cluster_setup/cluster_setup_src/master/
```
- 0_settings.sh: This script does not need to be executed, user need to write worker hostname filenames to it.
- 1_master_basics.sh
    - update automated settings in 0_settings.sh
    - install parallel-ssh and create corrsponding err and out logs dirs under ~/Documents/parallelssh
    - copy SSH keys for worker nodes login to ~/.ssh/config
    - check k8s_tools, download, git clone, and compile if needed
- 2_copy_files_to_workers.sh
    - copy scripts for installing kubeadm kubelet, kubectl, containerd,... to work nodes.
- 3_install_k8s_tools.sh
    - install kubeadm kubelet, kubectl, containerd,... on master node
- 4_install_k8s_workers.sh
    - install kubeadm kubelet, kubectl, containerd,... on all worker nodes
- 5_k8s_init.sh
    - run `kubeadm init ...` on master node, and install flannel pod-network plugin
- 6_k8s_workers_join.sh
    - run `kubeadm join ...` on all worker nodes
- 7_k8s_tools_install.sh
    - use `kubectl apply -f <k8s_tools>.yaml` to install k8s tools including Kepler and Kube-Prometheus

## Step-by-step guide

- change directory to /k8s_cluster_setup/cluster_setup_src/master
- update 0_settings.sh by specifying which worker hostname file should be used.
- run bash scripts from 1_master_basics.sh to 7_k8s_tools_install.sh. The current script cannot start until the previous script finish.
- Done! please run
    ```
    watch kubectl get pods -A -o wide
    ```
     to check if all pods are up and running.