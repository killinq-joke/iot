sudo apt install -y git

sudo kubectl create ns gitlab

sudo snap install helm --classic

echo "127.0.0.1 gitlab.internal.com" | sudo tee -a /etc/hosts

sudo helm repo add gitlab https://charts.gitlab.io/
sudo helm repo update 
sudo helm upgrade --install gitlab gitlab/gitlab \
  -n gitlab \
  -f https://gitlab.com/gitlab-org/charts/gitlab/raw/master/examples/values-minikube-minimum.yaml \
  --set global.hosts.domain=internal.com \
  --set global.hosts.externalIP=0.0.0.0 \
  --set global.hosts.https=false \
  --timeout 600s

sudo kubectl wait --for=condition=ready --timeout=1200s pod -l app=webservice -n gitlab

sudo kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 --decode

#sudo kubectl port-forward svc/gitlab-webservice-default -n gitlab 80:8181 2>&1 >/dev/null &
sudo kubectl apply -f /home/vagrant/gitlab/ingress.yaml