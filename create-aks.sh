#!/bin/bash

BASE_NAME="${1}"
SERVER_APP_ID="${2}"
SERVER_APP_PASSWORD="${3}"
CLIENT_APP_ID="${4}"
AKS_SP_CLIENT_ID="${5}"
AKS_SP_CLIENT_PASSWORD="${6}"
ENV="${7}

function usage() {
  echo "usage: ./create-aks.sh <aks-name> <server-app-id> <server-app-password> <client-app-id> <aks-sp-client_id> <aks-sp-client-password> <env>" 
}

if [ -z "${BASE_NAME}" ] || [ -z "${SERVER_APP_ID}" ] || [ -z "${SERVER_APP_PASSWORD}" ] || [ -z "${CLIENT_APP_ID}" ] || [ -z "${AKS_SP_CLIENT_ID}" ] || [ -z "${AKS_SP_CLIENT_PASSWORD}" ] || [ -z "${ENV}" ]
then
  usage
  exit 1
fi

export ARM_TENANT_ID=$(az account show --query tenantId -o tsv)
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)

function keyvaultRead () {
 az keyvault secret show --vault-name rpe-infra --name ${1} --query value -o tsv
}

export ARM_CLIENT_ID=$(keyvaultRead subscription-sp-client-id)
export ARM_CLIENT_SECRET=$(keyvaultRead subscription-sp-client-secret)

export TF_VAR_aks_sp_client_id=${AKS_SP_CLIENT_ID}
export TF_VAR_aks_sp_client_secret=${AKS_SP_CLIENT_PASSWORD}

export TF_VAR_aks_ad_client_app_id=${CLIENT_APP_ID}
export TF_VAR_aks_ad_server_app_id=${SERVER_APP_ID}
export TF_VAR_aks_ad_server_app_secret=${SERVER_APP_PASSWORD}

terraform init \
    -backend-config "storage_account_name=corestoragetest" \
    -backend-config "container_name=test" \
    -backend-config "resource_group_name=core-storage" \
    -backend-config "key=aks/${BASE_NAME}-2/terraform.tfstate"

terraform apply -var-file ${BASE_NAME}.tfvars \
   -auto-approve

./create-cluster-role-setup.sh ${BASE_NAME} ${ENV}
