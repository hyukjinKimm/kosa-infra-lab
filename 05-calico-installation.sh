#!/bin/bash

export KUBECONFIG=/etc/kubernetes/admin.conf
export PATH=$PATH:/root/bin
# Calico CRD YAML 파일 생성
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
        cidr: 192.168.0.0/16
        encapsulation: IPIPCrossSubnet
        #encapsulation: VXLAN
        # 하이퍼브이 encapsulation: VXLANCrossSubnet 
        natOutgoing: Enabled
        nodeSelector: all()
  registry: quay.io
EOF

helm repo add projectcalico https://docs.tigera.io/calico/charts
kubectl create namespace tigera-operator
helm install calico projectcalico/tigera-operator --version v3.27.5 --namespace tigera-operator
kubectl taint node controller1.example.com node-role.kubernetes.io/control-plane:NoSchedule-
kubectl apply -f calico-quay-crd.yaml
