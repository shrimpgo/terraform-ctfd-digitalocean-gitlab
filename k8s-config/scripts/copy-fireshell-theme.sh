#!/usr/bin/env bash

set -euo pipefail

KUBECONFIG=$1
KUBECTL="kubectl --kubeconfig $KUBECONFIG"
POD_NAME=$($KUBECTL get pods --namespace ctfd -l "app.kubernetes.io/name=ctfd,app.kubernetes.io/instance=ctfd" -o jsonpath="{.items[0].metadata.name}")
$KUBECTL cp frontend/fireshell-theme $POD_NAME:/opt/CTFd/CTFd/themes/ -c ctfd -n ctfd && rm $KUBECONFIG