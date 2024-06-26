export K3S_TOKEN="12345"
export K3S_URL="https://192.168.56.110:6443"
export INSTALL_K3S_EXEC="--token $K3S_TOKEN --server $K3S_URL"
export K3S_NODE_NAME=${HOSTNAME//_/-}
curl -sfL https://get.k3s.io | sh -
#https://github.com/k3s-io/k3s/issues/1523