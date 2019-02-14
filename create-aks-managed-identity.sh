#!/bin/bash

function usage() {
    echo "usage: ./create-aks-managed-identity.sh <aks-name> <aks-sp-id>"
}

export BASE_NAME=${1}
AKS_SP_IP=${2}

if [ -z "${BASE_NAME}" ] || [ -z "${AKS_SP_IP}" ]
then
    usage
    exit 1
fi

kubectl create -f https://raw.githubusercontent.com/Azure/aad-pod-identity/master/deploy/infra/deployment-rbac.yaml

export NODE_RESOURCE_GROUP=$(az aks show -g core-infra-${BASE_NAME} --name ${BASE_NAME} --query nodeResourceGroup -o tsv)
export IDENTITY_CLIENT_ID=$(az identity create -g ${NODE_RESOURCE_GROUP} -n ${BASE_NAME} --query clientId -o tsv)

sleep 10 # previous command finishes before its actually created https://github.com/Azure/azure-cli/issues/8530

export ARM_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
az role assignment create --role Reader --assignee ${IDENTITY_CLIENT_ID} --scope /subscriptions/${ARM_SUBSCRIPTION_ID}/resourcegroups/${NODE_RESOURCE_GROUP}

envsubst < templates/user-assigned-msi.template.yaml > templates/substituted/user-assigned-msi.yaml
kubectl apply -f templates/substituted/user-assigned-msi.yaml

envsubst < templates/azure-identity-binding.template.yaml > templates/substituted/azure-identity-binding.yaml
kubectl apply -f templates/substituted/azure-identity-binding.yaml

az role assignment create --role "Managed Identity Operator" --assignee ${AKS_SP_IP} --scope /subscriptions/${ARM_SUBSCRIPTION_ID}/resourceGroups/${NODE_RESOURCE_GROUP}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${BASE_NAME}