#!/bin/bash

export KUBECONFIG=/etc/kubernetes/admin.conf
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


# Helm repository 추가
echo "Adding Calico Helm repository..."
helm repo add projectcalico https://docs.tigera.io/calico/charts
# Helm repository 추가 확인
until helm repo list | grep -q 'projectcalico'; do
    echo "Waiting for Calico Helm repository to be added..."
    sleep 2
done

# 네임스페이스가 생성될 때까지 대기
echo "Creating tigera-operator namespace..."
kubectl create namespace tigera-operator
# 네임스페이스가 생성될 때까지 확인
until kubectl get namespace tigera-operator > /dev/null 2>&1; do
    echo "Waiting for tigera-operator namespace to be created..."
    sleep 2
done

# Tigera Calico operator 설치
echo "Installing Tigera Calico operator..."
helm install calico projectcalico/tigera-operator --version v3.27.5 --namespace tigera-operator

# Helm 릴리스가 설치되었는지 확인
until helm list --namespace tigera-operator | grep -q 'calico'; do
    echo "Waiting for Tigera Calico operator installation..."
    sleep 2
done

# Control-plane 노드에 taint 해제
echo "Removing taint from control-plane node..."
kubectl taint node node1.example.com node-role.kubernetes.io/control-plane:NoSchedule-

# Calico CRD 적용
echo "Applying Calico CRD..."
kubectl apply -f calico-quay-crd.yaml

# Calico 시스템의 pod 상태 확인
echo "Checking Calico system pod status..."
kubectl -n calico-system get pod
