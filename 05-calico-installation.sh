#!/bin/bash

export KUBECONFIG=/etc/kubernetes/admin.conf

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
        cidr: 192.168.10.0/16
        encapsulation: VXLAN
        # 하이퍼브이 encapsulation: VXLANCrossSubnet 
        natOutgoing: Enabled
        nodeSelector: all()
  registry: quay.io
EOF

# Helm repository 추가
echo "Adding Calico Helm repository..."
until helm repo add projectcalico https://docs.tigera.io/calico/charts && helm repo list | grep -q 'projectcalico'; do
    echo "Waiting for Calico Helm repository to be added..."
    sleep 2
done

# 네임스페이스가 생성될 때까지 대기
echo "Creating tigera-operator namespace..."
until kubectl create namespace tigera-operator && kubectl get namespace tigera-operator > /dev/null 2>&1; do
    echo "Waiting for tigera-operator namespace to be created..."
    sleep 2
done

# Tigera Calico operator 설치
echo "Installing Tigera Calico operator..."
until helm install calico projectcalico/tigera-operator --version v3.27.5 --namespace tigera-operator && helm list --namespace tigera-operator | grep -q 'calico'; do
    echo "Waiting for Tigera Calico operator installation..."
    sleep 2
done

# Control-plane 노드에 taint 해제
echo "Removing taint from control-plane node..."
until kubectl taint node node1.example.com node-role.kubernetes.io/control-plane:NoSchedule-; do
    echo "Waiting for taint removal from control-plane node..."
    sleep 2
done

# Calico CRD 적용
echo "Applying Calico CRD..."
until kubectl apply -f calico-quay-crd.yaml; do
    echo "Waiting for Calico CRD application..."
    sleep 2
done

# Calico 시스템의 pod 상태 확인
echo "Checking Calico system pod status..."
until kubectl -n calico-system get pod > /dev/null 2>&1; do
    echo "Waiting for Calico system pods to be ready..."
    sleep 2
done
