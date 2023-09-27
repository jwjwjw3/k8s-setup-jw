#!/usr/bin/bash 
# this script needs to be executed on the master node, in root account or using sudo.

# sudo mkdir $k8s_cluster_setup_pdir 
# sudo mount /dev/vdd $k8s_cluster_setup_pdir

# update the basic settings and setup script dirs
sed -i '/k8s_cluster_setup_pdir/d' ./0_settings.sh
echo "k8s_cluster_setup_pdir=$(dirname $(dirname $(dirname "`pwd`")))" >> 0_settings.sh
source ./0_settings.sh

# create necessary directories for scripts and data
mkdir $k8s_cluster_setup_pdir/k8s_cluster_setup/worker_hostnames
# mkdir $HOME/Downloads
mkdir $HOME/Documents
# mkdir $HOME/Documents/k8s
mkdir $HOME/Documents/parallelssh
mkdir $HOME/Documents/parallelssh/tmpoutputs
mkdir $HOME/Documents/parallelssh/tmperrors

# install parallel-ssh and wget
sudo apt update && sudo apt install pssh wget -y

# copy ssh keys and update ssh settings to make sure parallel-ssh can run scripts smoothly
cp $k8s_cluster_setup_pdir/k8s_cluster_setup/cluster_setup_src/ssh_credentials/id_rsa $HOME/.ssh/id_rsa
cp $k8s_cluster_setup_pdir/k8s_cluster_setup/cluster_setup_src/ssh_credentials/id_rsa.pub $HOME/.ssh/id_rsa.pub
# update ssh config file
if [ -f $HOME/.ssh/config ]; then
    echo "$HOME/.ssh/config exists."
else 
    echo "$HOME/.ssh/config does not exist, creating file..."
    touch $HOME/.ssh/config
fi
sshConfigPatternLines=$(grep -c 'StrictHostKeyChecking no' $HOME/.ssh/config)
if [ $sshConfigPatternLines -eq 0 ]; then 
    echo "Host *" >> $HOME/.ssh/config
    echo "   StrictHostKeyChecking no" >> $HOME/.ssh/config
else 
    echo "ssh config line 'StrictHostKeyChecking no' found in $HOME/.ssh/config, assuming this is set for all hosts already."
fi

# download and compile if required k8s tools are not present
mkdir $k8s_cluster_setup_pdir/k8s_cluster_setup/k8s_tools
# check flannel
if [ -d $k8s_cluster_setup_pdir/k8s_cluster_setup/k8s_tools/flannel ] 
then
    echo "flannel directory found, assuming flannel yaml file already exists."
else
    mkdir $k8s_cluster_setup_pdir/k8s_cluster_setup/k8s_tools/flannel
    wget -O $k8s_cluster_setup_pdir/k8s_cluster_setup/k8s_tools/flannel/kube-flannel_release_v0.22.1.yml https://github.com/flannel-io/flannel/releases/download/v0.22.1/kube-flannel.yml
fi
# check Kube-Prometheus
if [ -d $k8s_cluster_setup_pdir/k8s_cluster_setup/k8s_tools/kube-prometheus ] 
then
    echo "kube-prometheus directory found, assuming kube-prometheus is already git cloned and switched to appropriate branch."
else
    git clone https://github.com/prometheus-operator/kube-prometheus.git $k8s_cluster_setup_pdir/k8s_cluster_setup/k8s_tools/kube-prometheus
    cd $k8s_cluster_setup_pdir/k8s_cluster_setup/k8s_tools/kube-prometheus
    git checkout release-0.12
    cd $k8s_cluster_setup_pdir/k8s_cluster_setup/cluster_setup_src/master
fi
# check Kepler
if [ -d $k8s_cluster_setup_pdir/k8s_cluster_setup/k8s_tools/kepler ] 
then
    echo "kepler directory found, assuming kepler is already git cloned and switched to appropriate branch."
else
    git clone https://github.com/sustainable-computing-io/kepler.git $k8s_cluster_setup_pdir/k8s_cluster_setup/k8s_tools/kepler
    cd $k8s_cluster_setup_pdir/k8s_cluster_setup/k8s_tools/kepler
    git checkout release-0.5.5
    rm -r _output
    sudo apt install make golang -y
    make build-manifest OPTS="PROMETHEUS_DEPLOY ESTIMATOR_SIDECAR_DEPLOY"
    cd $k8s_cluster_setup_pdir/k8s_cluster_setup/cluster_setup_src/master    
fi