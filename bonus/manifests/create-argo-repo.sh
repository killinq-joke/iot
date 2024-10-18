#!/bin/bash

JSON_FMT='{
  "apiVersion": "v1",
  "kind": "Secret",
  "metadata": {
    "name": "my-private-https-repo",
    "namespace": "argocd",
    "labels": {
      "argocd.argoproj.io/secret-type": "repository"
    }
  },
  "stringData": {
    "url": "http://%s:8181/root/test.git",
    "password": "%s",
    "username": "root",
    "insecure": "true",
    "forceHttpBasicAuth": "true",
    "enableLfs": "true"
  }
}'

SVC=$(sudo kubectl get svc -n gitlab | grep "gitlab-webservice-default" | cut -d " " -f 7 )

PASSWORD_ARGO=$(sudo kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -o jsonpath="{.data.password}" | base64 -d)

printf "$JSON_FMT" "$SVC" "$PASSWORD_ARGO" > argo-repo.yaml