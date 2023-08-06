#!/usr/bin/bash 
# this script needs to be executed on the master node in root account.

source 0_settings.sh

# install kube-prometheus
kubectl apply --server-side -f $k8s_cluster_setup_pdir/k8s_cluster_setup/k8s_tools/kube-prometheus/manifests/setup
kubectl wait \
	--for condition=Established \
	--all CustomResourceDefinition \
	--namespace=monitoring
kubectl apply -f $k8s_cluster_setup_pdir/k8s_cluster_setup/k8s_tools/kube-prometheus/manifests/

# install kepler
kubectl apply -f $k8s_cluster_setup_pdir/k8s_cluster_setup/k8s_tools/kepler/_output/generated-manifest/deployment.yaml

echo "waiting for 10s for prometheus to start..."
sleep 10
# enable memory snapshot, recommended for taking prometheus TSDB snapshots later.
kubectl -n monitoring patch prometheus k8s --type merge --patch '{"spec":{"enableFeatures":["memory-snapshot-on-shutdown"]}}'
# enable admin api for taking snapshots later
kubectl -n monitoring patch prometheus k8s --type merge --patch '{"spec":{"enableAdminAPI":true}}'

# create new screen sessions for looping-forever kubectl prometheus port forwarding
# Note: a screen can be killed by command: screen -XS screen_id quit
sudo apt install screen
if ! screen -list | grep -q pmt_port_forward; then
    echo "starting prometheus port forwarding screen..."
	# screen -S pmt_port_forward -d -m ./runtime_scripts/prometheus_port_forward.sh
	screen -S pmt_port_forward -d -m bash -c "while true; do kubectl --namespace monitoring port-forward svc/prometheus-k8s 9090; done;"
else 
    echo "prometheus port forwarding screen detected, assuming it is working normally..."
fi
# if ! screen -list | grep -q pmt_port_keep_alive; then
#     echo "starting port forwarding keeping alive screen..."
# 	# screen -S pmt_port_keep_alive -d -m -t ./runtime_scripts/port_forward_keep_alive.sh
# 	screen -S pmt_port_keep_alive -d -m bash -c "while true; do nc -vz 127.0.0.1 9090; sleep 10; done;"
# else 
#     echo "port forwarding keeping alive screen detected, assuming it is working normally..."
# fi