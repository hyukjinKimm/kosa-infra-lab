#!/bin/bash

export KUBECONFIG=/etc/kubernetes/admin.conf
export PATH=$PATH:/root/bin
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
