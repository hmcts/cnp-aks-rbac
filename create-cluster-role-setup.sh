#!/bin/bash

BASE_NAME="${1}"

function usage() {
  echo "usage: ./create-aks.sh <aks-name>"
}

if [ -z "${BASE_NAME}" ]; then
  usage
  exit 1
fi

export DEVELOPERS_GROUP=fbd14e44-da3c-4305-8731-0060f56c296f
export AKS_CLUSTER_READER=3043c9ac-a03c-419c-89ac-cbe1e83d461d

CLUSTER_ADMINS_GROUP_NAME="${BASE_NAME}-cluster-admins"
export CLUSTER_ADMIN_GROUP=$(az ad group list --query  "[?displayName=='${CLUSTER_ADMINS_GROUP_NAME}'].objectId" -o tsv)

az aks get-credentials --resource-group ${BASE_NAME} --name ${BASE_NAME} --admin --overwrite

mkdir -p templates/substituted

envsubst < templates/cluster-admin-binding.template.yaml > templates/substituted/cluster-admin-binding.yaml
kubectl apply -f templates/substituted/cluster-admin-binding.yaml

envsubst < templates/developers-log-reader-binding.template.yaml > templates/substituted/developers-log-reader-binding.yaml
kubectl apply -f templates/substituted/developers-log-reader-binding.yaml

envsubst < templates/view-binding.template.yaml > templates/substituted/view-binding.yaml
kubectl apply -f templates/substituted/view-binding.yaml

if [ "${DEVELOPERS_EDIT_GLOBAL_SCOPED}" == "true" ]; then
    echo "Developers edit access at cluster level enabled"
    envsubst < templates/developers-edit-binding.template.yaml > templates/substituted/developers-edit-binding.yaml
    kubectl apply -f templates/substituted/developers-edit-binding.yaml
fi