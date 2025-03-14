# Kubernetes Cluster Setup on Rocky Linux 9 with CRI-O and Flannel CNI

Rocky Linux 9 환경에서 Kubernetes 클러스터를 설치하고 설정하는 코드.

## 파일 설명

### 01-node-configure.sh

Kubernetes와 CRI-O의 리포지토리를 설정하고, 필요한 패키지들을 설치하며, 시스템 구성을 진행.


### 02-kubeadm-controller.sh

Kubernetes 컨트롤러 노드를 초기화하는 스크립트.

 **Kubeadm 초기화**
   - `kubeadm init` 명령을 실행하여 Kubernetes 마스터 노드를 초기화
   - `control-plane-endpoint` 옵션으로 로드밸런서 주소를 설정하고, `pod-network-cidr`는 Flannel 네트워크를 위한 CIDR 주소를 설정.


### 04-helm-controller.sh

Kubernetes 컨트롤러에서 Helm을 설치하는 스크립트.

 **Helm 설치**
   - Helm 설치 스크립트를 다운로드하여 Helm을 설치.
   - Helm을 `/usr/local/bin/` 디렉토리에서 `/root/bin/`로 이동.
    

### 05-flannel-installation.sh

Kubernetes 클러스터에 Flannel CNI(네트워크 플러그인)를 설치하는 스크립트.

1. **Kubeconfig 설정**
   - `KUBECONFIG` 환경 변수를 설정하여 `kubectl` 명령어가 올바른 kubeconfig 파일을 사용할 수 있게 함.

2. **Flannel 설치**
   - Flannel CNI를 Kubernetes에 설치하기 위해 `kubectl apply` 명령을 실행하여 Flannel의 배포 파일을 클러스터에 적용.


