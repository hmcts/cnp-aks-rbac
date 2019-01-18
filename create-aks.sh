#!/bin/bash

BASE_NAME="${1}"
SERVER_APP_ID="${2}"
SERVER_APP_PASSWORD="${3}"
CLIENT_APP_ID="${4}"

function usage() {
  echo "usage: ./create-aks.sh <aks-name> <server-app-id> <server-app-password> <client-app-id>" 
}

if [ -z "${BASE_NAME}" ] || [ -z "${SERVER_APP_ID}" ] || [ -z "${SERVER_APP_PASSWORD}" ] || [ -z "${CLIENT_APP_ID}" ]
then
  usage
  exit 1
fi

az group create --name ${BASE_NAME} --location uksouth

TENANT_ID=$(az account show --query tenantId -o tsv)

az aks create \
  --resource-group ${BASE_NAME} \
  --name ${BASE_NAME} \
  --generate-ssh-keys \
  --aad-server-app-id ${SERVER_APP_ID} \
  --aad-server-app-secret ${SERVER_APP_PASSWORD} \
  --aad-client-app-id ${CLIENT_APP_ID} \
  --aad-tenant-id ${TENANT_ID} \
  --kubernetes-version 1.11.5 \
  --location uksouth

./create-cluster-role-setup.sh ${BASE_NAME}

# TODO - we will want to add these so that azure doesn't generate for us:
# --network-plugin azure
# "aksVnetResourceGroup"
# "aksVnetName"
# "aksSubnetName"
# "dnsPrefix"
# "sshPublicKey"
# disk size (30 GB is default I think and prob too small)
# vm type (use B-series for nonprod clusters)
# node count
# SP username and password (if we're creating beforehand in future)