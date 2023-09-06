#!/usr/bin/bash 
# this script needs to be executed on the master node in root account.

source 0_settings.sh

pmt_pod_name="prometheus-k8s-1"
snapshot_target_dir="/root/prometheus_snapshots-2nd/"

echo "getting information from pod: $pmt_pod_name"
pmt_pod_line=`kubectl get pods -n monitoring -o wide | grep $pmt_pod_name`
pmt_pod_PatternLines=`echo $pmt_pod_line | grep -c 'ago)'`
if [ $pmt_pod_PatternLines -eq 0 ]; then 
    pmt_pod_ip=`echo $pmt_pod_line | awk '{ print $6 }'`
else 
    pmt_pod_ip=`echo $pmt_pod_line | awk '{ print $8 }'`
fi
echo "pod internal IP is: $pmt_pod_ip"

echo "deleting previous existing snapshots on pod: $pmt_pod_name"
kubectl exec -it -n monitoring $pmt_pod_name -- rm -r /prometheus/snapshots

echo "sending request for generating prometheus snapshot on pod: $pmt_pod_name"
pmt_pod_snapshot_gen_result=`curl -XPOST http://$pmt_pod_ip:9090/api/v1/admin/tsdb/snapshot`
echo "prometheus snapshot generation result: $pmt_pod_snapshot_gen_result"

if [[ $pmt_pod_snapshot_gen_result == *"success"* ]]; then
    echo "snapshot generated successfully, trying to clean up destination folder: $snapshot_target_dir"
    rm -r $snapshot_target_dir
    echo "copying results from $pmt_pod_name to $snapshot_target_dir"
    kubectl cp -n monitoring $pmt_pod_name:/prometheus/snapshots/ $snapshot_target_dir
else
    echo "snapshot generation failed"
fi