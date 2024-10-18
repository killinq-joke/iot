gitlab_api="http://$(sudo kubectl get ing -n gitlab -o jsonpath="{.status.loadBalancer.ingress[].ip}" gitlab-ingress)"
gitlab_user="root"
gitlab_password=$(sudo kubectl get secrets -n gitlab gitlab-gitlab-initial-root-password -ojsonpath="{.data.password}" | base64 -d)

echo 'grant_type=password&username='$gitlab_user'&password='$gitlab_password > auth.txt

oauth_token=$(curl -s --request POST "$gitlab_api/oauth/token" --data "@auth.txt")
echo "oauth-token : $oauth_token"

access_token=$(echo $oauth_token | cut -d "\"" -f4)
echo "access token : $access_token"

id_user=$(curl --header "Authorization: Bearer $access_token" "$gitlab_api/oauth/token/info" -s | cut -d ":" -f2 | cut -d "," -f1)
echo "id_user : $id_user"

# response=$(curl --request POST "$gitlab_api/v4/users/$id_user/personal_access_tokens" \
#     --header "PRIVATE-TOKEN: $access_token" \
#     --data "name=root-token&scopes[]=api" \
# )

#curl --request POST "$gitlab_api/api/v4/users?access_token=$access_token" \
#  --data "email=user@example.com&password=securepassword&username=newuser&name=New User"

#curl -s --request GET "$gitlab_api/api/v4/users?access_token=$access_token"

ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519

add_ssh_key () {
        curl --request POST "$gitlab_api/api/v4/users/$id_user/keys/?access_token=$access_token" \
        --form "title=newkey" \
        --form "key=$ssh_public_key" \
        --form "expires_at=2024-10-25"
}

add_ssh_key

create_project () {
        curl --request POST "$gitlab_api/api/v4/projects/?access_token=$access_token" \
        --data "name=test" \
        --data "visibility=private"
}

create_project

cd ../kustomize

git init

git remote add lab ssh://git@172.18.0.2:32022/root/test.git

git config --global user.email "you@example.com"

git config --global user.name "Your Name"

git add .

git commit -m "init"

git push -u lab master