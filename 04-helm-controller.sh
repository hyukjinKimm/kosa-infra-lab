#!/bin/bash

export PATH=$PATH:/usr/local/bin
export KUBECONFIG=/etc/kubernetes/admin.conf

dnf install git tar -y
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
mkdir ~/bin
sh get_helm.sh
mv /usr/local/bin/helm ~/bin


cat <<EOF> calico-quay-crd.yaml
---
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  calicoNetwork:
    ipPools:
      - blockSize: 26
        cidr: 192.168.10.0/16
        encapsulation: VXLAN
        # 하이퍼브이 encapsulation: VXLANCrossSubnet 
        natOutgoing: Enabled
        nodeSelector: all()
  registry: quay.io
EOF

helm repo add projectcalico https://docs.tigera.io/calico/charts
kubectl create namespace tigera-operator
helm install calico projectcalico/tigera-operator --version v3.27.5 --namespace tigera-operator
kubectl taint node node1.example.com node-role.kubernetes.io/control-plane:NoSchedule-
kubectl apply -f calico-quay-crd.yaml
