#!/usr/bin/bash 
# this script needs to be executed on the master node, in root account or using sudo.

# sudo mkdir $k8s_cluster_setup_pdir 
# sudo mount /dev/vdd $k8s_cluster_setup_pdir

# install basic network tools
# sudo apt update && sudo apt install avahi-utils vim -y

# remove swap memory line from /etc/fstab and then reboot
# no need in IBM cloud VMs

# update the basic settings and setup script dirs
sed -i '/k8s_cluster_setup_pdir/d' ./0_settings.sh
echo "k8s_cluster_setup_pdir=$(dirname $(dirname $(dirname "`pwd`")))" >> 0_settings.sh
source ./0_settings.sh

# create necessary directories for scripts and data
mkdir $k8s_cluster_setup_pdir/k8s_cluster_setup/worker_hostnames
# mkdir ~/Downloads
mkdir ~/Documents
# mkdir ~/Documents/k8s
mkdir ~/Documents/parallelssh
mkdir ~/Documents/parallelssh/tmpoutputs
mkdir ~/Documents/parallelssh/tmperrors

# install parallel-ssh and wget
sudo apt update && sudo apt install pssh wget -y

# copy ssh keys and update ssh settings to make sure parallel-ssh can run scripts smoothly
cp $k8s_cluster_setup_pdir/k8s_cluster_setup/cluster_setup_src/ssh_credentials/id_rsa ~/.ssh/id_rsa
cp $k8s_cluster_setup_pdir/k8s_cluster_setup/cluster_setup_src/ssh_credentials/id_rsa.pub ~/.ssh/id_rsa.pub
echo "Host *" >> ~/.ssh/config
echo "   StrictHostKeyChecking no" >> ~/.ssh/config

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
if [ -d $k8s_cluster_setup_pdir/k8s_cluster_setup/k8s_tools/kube-prometheus ] 
then
    echo "kepler directory found, assuming kepler is already git cloned and switched to appropriate branch."
else
    git clone https://github.com/sustainable-computing-io/kepler.git $k8s_cluster_setup_pdir/k8s_cluster_setup/k8s_tools/kepler
    cd $k8s_cluster_setup_pdir/k8s_cluster_setup/k8s_tools/kepler
    git checkout release-0.5.3
    rm -r _output
    sudo apt install make golang -y
    make build-manifest OPTS="PROMETHEUS_DEPLOY"
    cd $k8s_cluster_setup_pdir/k8s_cluster_setup/cluster_setup_src/master    
fi

#####################################################################

# add git configs
git config --global user.name jinghua-ibmcloud
git config --global user.email jinghua@ibmcloud-master

# add conda init lines to .bashrc
condaPatternLines=$(grep -c '>>> conda initialize >>>' $HOME/.bashrc)
if [ $condaPatternLines -eq 0 ]; then 
    tee -a ~/.bashrc > /dev/null <<EOT
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="\$('/media/d/programs/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ \$? -eq 0 ]; then
    eval "\$__conda_setup"
else
    if [ -f "/media/d/programs/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/media/d/programs/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/media/d/programs/anaconda3/bin:\$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

conda activate eehc
EOT
    echo "conda init arguments added into $HOME/.bashrc"
else 
    echo "conda init segments already found in $HOME/.bashrc"
fi
# source $HOME/.bashrc


# # config cgroup settings to prevent potential k8s runtime issues, and then reboot
# seems not needed on IBM cloud VMs, but needed for VirtualBox VMs on Win 10.
# sudo sed -i 's#^\(GRUB_CMDLINE_LINUX_DEFAULT="quiet splash\)"$#\1 systemd.unified_cgroup_hierarchy=0"#' /etc/default/grub
# sudo update-grub
# sudo reboot