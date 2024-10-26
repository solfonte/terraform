#!/bin/bash

echo "Arg 1: $1"
if [["$1" == ""]];
then
    echo "enter USER_NAME"
    exit
fi

USER_JSON=""
echo "Creating iam user"
while IFS= read -r line; do
    echo $line
done <<< $(awslocal iam create-user --user-name "$1") 


echo "Creating access keys"
accessKeyID=""
secretAccessKey=""
while IFS= read -r line; do
    echo "$line"
    
    if [[ $line =~ "AccessKeyId" ]];
    then
        accessKeyID=$(echo $line | sed -E 's/.*"AccessKeyId": "(.*)"/\1/' | sed 's/,$//')
    elif [[ $line =~ "SecretAccessKey" ]];
    then
        secretAccessKey=$(echo $line | sed -E 's/.*"SecretAccessKey": "(.*)"/\1/' | sed 's/,$//')
    fi
done <<< $(awslocal iam create-access-key --user-name "$1")

echo "Access key id: $accessKeyID"
echo "Secret Access key: $secretAccessKey"

# export TF_VAR_access_key=$accessKeyID
# export TF_VAR_secret_key=$secretAccessKey