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

# # (optional, wait and then do port forwarding for accessing Prometheus WebUI)
# sleep 10
# kubectl --namespace monitoring port-forward svc/prometheus-k8s 9090