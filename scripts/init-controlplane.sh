export K3S_NODE_NAME=${HOSTNAME//_/-}
export K3S_EXTERNAL_IP="192.168.56.110"
export INSTALL_K3S_EXEC="--token=12345 --write-kubeconfig ~/.kube/config --write-kubeconfig-mode 666 --tls-san $K3S_EXTERNAL_IP --kube-apiserver-arg service-node-port-range=1-65000 --kube-apiserver-arg advertise-address=$K3S_EXTERNAL_IP --kube-apiserver-arg external-hostname=$K3S_EXTERNAL_IP"
curl -sfL https://get.k3s.io | sh -
#https://github.com/k3s-io/k3s/issues/1523