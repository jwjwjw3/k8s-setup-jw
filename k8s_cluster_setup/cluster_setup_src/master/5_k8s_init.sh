#!/usr/bin/bash 
# this script needs to be executed on the master node in root account.

source 0_settings.sh

# start k8s cluster from master node 
# if using dockerd, need option: --cri-socket=unix:///var/run/cri-dockerd.sock
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 

# add k8s configs
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


echo ""
echo "Waiting to install network plugin..."
sleep 10

# # install calico (if not continuously fail within 30s)
# NEXT_WAIT_TIME=0
# until [ $NEXT_WAIT_TIME -eq 30 ] || kubectl apply -f $k8s_cluster_setup_pdir/k8s_cluster_setup/k8s_tools/calico/calico.yaml; do
#     sleep $(( NEXT_WAIT_TIME++ ))
# done
# [ $NEXT_WAIT_TIME -lt 30 ]

# install flannel
# kubectl apply -f https://github.com/flannel-io/flannel/releases/download/v0.22.1/kube-flannel.yml
kubectl apply -f $k8s_cluster_setup_pdir/k8s_cluster_setup/k8s_tools/flannel/kube-flannel_release_v0.22.1.yml

