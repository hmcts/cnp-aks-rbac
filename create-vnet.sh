#!/bin/bash

ENV="${1}"

function usage() {
  echo "usage: ./create-vnet.sh <env>" 
}

if [ -z "${ENV}" ] ; then
  usage
  exit 1
fi

function keyvaultRead () {
 az keyvault secret show --vault-name rpe-infra --name ${1} --query value -o tsv
}

cd createVnet

export ARM_TENANT_ID=$(az account show --query tenantId -o tsv)
export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)

export ARM_CLIENT_ID=$(keyvaultRead subscription-sp-client-id)
export ARM_CLIENT_SECRET=$(keyvaultRead subscription-sp-client-secret)

terraform init \
    -backend-config "storage_account_name=corestoragetest" \
    -backend-config "container_name=test" \
    -backend-config "resource_group_name=core-storage" \
    -backend-config "key=core-infra/${ENV}/terraform.tfstate"

terraform apply -var-file ${ENV}.tfvars -var env=${ENV} \
  -auto-approve