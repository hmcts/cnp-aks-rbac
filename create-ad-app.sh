#!/bin/bash

BASE_NAME="${1}"

SERVER_APP_NAME="${BASE_NAME}-server"
CLIENT_APP_NAME="${BASE_NAME}-client"

function usage() {
  echo "usage: ./create-ad-app.sh <app-name>" 
}

if [ -z "${BASE_NAME}" ]; then
  usage
  exit 1
fi

SERVER_APP_PASSWORD=$(openssl rand -base64 32 | grep -o  '[[:alnum:]]' | tr -d '\n')

export SERVER_APP_ID=$(az ad app create --display-name ${SERVER_APP_NAME} --required-resource-accesses @server-manifest.json  --identifier-uri http://AKSAADServer-${SERVER_APP_NAME} --password ${SERVER_APP_PASSWORD} --query appId -o tsv)

echo "Ignore the warning about \"Property 'groupMembershipClaims' not found on root\""
az ad app update --id ${SERVER_APP_ID} --set groupMembershipClaims=All

envsubst < client-manifest.template.json > client-manifest.json

while true; do
    read -p "You now need to go to the portal, and grant permissions for ${SERVER_APP_NAME}, after complete type (done)? " answer
    case $answer in
        [dD]* ) break;;
        * ) echo "Please answer with 'done'";;
    esac
done

CLIENT_APP_ID=$(az ad app create --display-name ${CLIENT_APP_NAME} --native-app --required-resource-accesses @client-manifest.json  --query appId -o tsv)

echo "Server app ID: ${SERVER_APP_ID}"
echo "Server app password: ${SERVER_APP_PASSWORD}"
echo "Server app display name: ${SERVER_APP_NAME}"

echo "Client app ID: ${CLIENT_APP_ID}"
echo "Client app display name: ${CLIENT_APP_NAME}"

./create-aks.sh ${BASE_NAME} ${SERVER_APP_ID} ${SERVER_APP_PASSWORD} ${CLIENT_APP_ID}