#!/bin/bash

namespaces=$(kubectl get ns | grep 'cattle\|fleet\|p-' | awk '{print $1}')
array=($namespaces)
length=${#array[@]}

if [ "$length" -eq 0 ]; then
    echo "There's no pending namespaces for cleaning"
    echo "Exiting"
    exit 0 
fi

for ns in $namespaces; do
    kubectl get namespace $ns -o json > namespace.json
    jq 'del(.metadata.finalizers)' namespace.json > temp.json
    jq 'del(.spec)' temp.json > namespace.json
    kubectl replace --raw "/api/v1/namespaces/$ns/finalize" -f ./namespace.json
    echo "Namespace ${ns} deleted."
done