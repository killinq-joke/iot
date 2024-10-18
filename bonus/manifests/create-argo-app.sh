#!/bin/bash

JSON_FMT='{
  "apiVersion": "argoproj.io/v1alpha1",
  "kind": "Application",
  "metadata": {
    "name": "mywebapp",
    "namespace": "argocd"
  },
  "spec": {
    "project": "default",
    "source": {
      "repoURL": "http://%s:8181/root/test.git",
      "targetRevision": "HEAD",
      "path": "kustomize/"
    },
    "destination": {
      "server": "https://kubernetes.default.svc",
      "namespace": "dev"
    },
    "syncPolicy": {
      "automated": {
        "prune": true,
        "allowEmpty": true,
        "selfHeal": true
      }
    }
  }
}'

SVC=$(sudo kubectl get svc -n gitlab | grep "gitlab-webservice-default" | cut -d " " -f 7 )

printf "$JSON_FMT" "$SVC" > argo-app.yaml