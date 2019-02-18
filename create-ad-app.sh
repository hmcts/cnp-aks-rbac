#!/bin/bash

BASE_NAME="${1}"

SERVER_APP_NAME="${BASE_NAME}-server"
CLIENT_APP_NAME="${BASE_NAME}-client"

function usage() {
  echo "usage: ./create-ad-app.sh <app-name>" 
}

if [ -z "${BASE_NAME}" ] ; then
  usage
  exit 1
fi

SERVER_APP_PASSWORD=$(openssl rand -base64 32 | grep -o  '[[:alnum:]]' | tr -d '\n')

export SERVER_APP_ID=$(az ad app create --display-name ${SERVER_APP_NAME} --required-resource-accesses @server-manifest.json  --identifier-uri http://AKSAADServer-${SERVER_APP_NAME} --password ${SERVER_APP_PASSWORD} --query appId -o tsv)

echo "Ignore the warning about \"Property 'groupMembershipClaims' not found on root\""
az ad app update --id ${SERVER_APP_ID} --set groupMembershipClaims=All

envsubst < client-manifest.template.json > client-manifest.json

while true; do
    read -p "You now need to go to the portal, Azure AD -> app registrations -> ${SERVER_APP_NAME} -> settings -> required permissions, click grant permissions, after complete type (done)? " answer
    case $answer in
        [dD]* ) break;;
        * ) echo "Please answer with 'done'";;
    esac
done

CLIENT_APP_ID=$(az ad app create --display-name ${CLIENT_APP_NAME} --native-app --reply-urls http://localhost/client --required-resource-accesses @client-manifest.json  --query appId -o tsv)
CLIENT_SP_OBJECT_ID=$(az ad sp create --id ${CLIENT_APP_ID} --query objectId -o tsv)

# without the sleep I was getting: 
# Operation failed with status: 'Bad Request'. Details: 400 Client Error: Bad Request for url: https://graph.windows.net/a0d77fc4-df1e-4b0d-8e35-46750ca5a672/oauth2PermissionGrants?api-version=1.6
sleep 5

# You can only add delegated permissions via the CLI
# see support case: 119011625000863
az ad app permission grant --id ${CLIENT_SP_OBJECT_ID} --api ${SERVER_APP_ID}

az group create --name ${BASE_NAME} --location uksouth

SUBSCRIPTION_ID=$(az account show --query id -o tsv)

VNET_RG=core-infra-${BASE_NAME}
VNET_NAME=${BASE_NAME}

AKS_SP=$(az ad sp create-for-rbac --name http://${BASE_NAME} \
  --role contributor \
  --scopes /subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${BASE_NAME} /subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${VNET_RG}/providers/Microsoft.Network/virtualNetworks/${VNET_NAME})

AKS_SP_APP_ID=$(echo ${AKS_SP} | jq -r .appId)
AKS_SP_APP_PASSWORD=$(echo ${AKS_SP} | jq -r .password)

CLUSTER_ADMINS_GROUP_NAME="${BASE_NAME}-cluster-admins"
CLUSTER_ADMIN_GROUP=$(az ad group list --query  "[?displayName=='${CLUSTER_ADMINS_GROUP_NAME}'].objectId" -o tsv)

if [ -z "${CLUSTER_ADMIN_GROUP}" ]; then 
    echo "Cluster admin group doesn't exist, creating"
    CLUSTER_ADMIN_GROUP=$(az ad group create  --display-name ${CLUSTER_ADMINS_GROUP_NAME} --mail-nickname ${CLUSTER_ADMINS_GROUP_NAME} --query objectId -o tsv)
fi

echo "Server app ID: ${SERVER_APP_ID}"
echo "Server app password: ${SERVER_APP_PASSWORD}"
echo "Server app display name: ${SERVER_APP_NAME}"

echo "Client app ID: ${CLIENT_APP_ID}"
echo "Client app display name: ${CLIENT_APP_NAME}"

echo "AKS SP client id: ${AKS_SP_APP_ID}"
echo "AKS SP client secret: ${AKS_SP_APP_PASSWORD}"

./create-aks.sh ${BASE_NAME} ${SERVER_APP_ID} ${SERVER_APP_PASSWORD} ${CLIENT_APP_ID} ${AKS_SP_APP_ID} ${AKS_SP_APP_PASSWORD}
