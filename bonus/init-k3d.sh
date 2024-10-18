#!/bin/bash
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
sudo k3d cluster create mycluster --api-port 6550 -p "8081:80@loadbalancer" --wait
export KUBECONFIG=$(sudo k3d kubeconfig write mycluster)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
sudo chmod +x /home/vagrant/gitlab/init.sh
sudo /home/vagrant/gitlab/init.sh
sudo kubectl create ns argocd
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
sudo kubectl create ns dev
sudo kubectl apply -f ./manifests/argo-ingress.yaml
sudo kubectl patch -n argocd deploy argocd-server --patch-file ./manifests/argo-insecure.yaml
sudo kubectl wait --for=condition=ready pod -n argocd -l app.kubernetes.io/name=argocd-server
cd manifests
sudo ./create-argo-repo.sh
sudo ./create-argo-app.sh
sudo kubectl apply -f ./argo-repo.yaml
sudo kubectl apply -f ./argo-app.yaml
