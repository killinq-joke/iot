#!/bin/bash
apk add docker
addgroup username docker
rc-update add docker default
service docker start
rc-update add cgroups
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
sudo k3d cluster create mycluster --api-port 6550 -p "8081:80@loadbalancer" --wait
export KUBECONFIG=$(sudo k3d kubeconfig write mycluster)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
sudo kubectl create ns argocd
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
sudo kubectl create ns dev
sudo kubectl apply -f ./manifests/argo-ingress.yaml
sudo kubectl patch -n argocd deploy argocd-server --patch-file ./manifests/argo-insecure.yaml
sudo kubectl wait --for=condition=ready pod -n argocd -l app.kubernetes.io/name=argocd-server
sudo kubectl apply -f ./manifests/argo-app.yaml
# sleep 5
# yes | argocd login $(sudo kubectl get ing argocd-ingress -n argocd -o jsonpath="{.status.loadBalancer.ingress[0].ip}") --username=admin --password=$(sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
# argocd app create mywebapp --repo https://github.com/killinq-joke/iot --path p3/kustomize --dest-namespace dev --dest-server https://kubernetes.default.svc --sync-policy=auto