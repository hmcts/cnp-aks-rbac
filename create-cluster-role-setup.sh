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
export CMC_GROUP=94bfcae1-11e0-4723-bef8-e6f3925eb55e
export PROBATE_GROUP=cb3b15bc-bd18-4d17-bc52-1f4dc77afdad
export DIVORCE_GROUP=439c3560-c51b-4c3f-8523-c1cee0e3fe0d
export AKS_CLUSTER_READER=3043c9ac-a03c-419c-89ac-cbe1e83d461d

CLUSTER_ADMINS_GROUP="${BASE_NAME}-cluster-admins"

export CLUSTER_ADMIN_GROUP=$(az ad group list --query  "[?displayName=='${CLUSTER_ADMINS_GROUP}'].objectId" -o tsv)

if [ -z "${CLUSTER_ADMIN_GROUP}" ]; then 
  echo "Cluster admin group doesn't exist, creating"
  export CLUSTER_ADMIN_GROUP=$(az ad group create  --display-name ${CLUSTER_ADMINS_GROUP} --mail-nickname ${CLUSTER_ADMINS_GROUP} --query objectId -o tsv)

else
  echo "Cluster admin group already exists, skipping create"
fi 

az aks get-credentials --resource-group ${BASE_NAME} --name ${BASE_NAME} --admin

mkdir -p templates/substituted

envsubst < templates/cluster-admin-binding.template.yaml > templates/substituted/cluster-admin-binding.yaml
kubectl apply -f templates/substituted/cluster-admin-binding.yaml

envsubst < templates/developers-log-reader-binding.template.yaml > templates/substituted/developers-log-reader-binding.yaml
kubectl apply -f templates/substituted/developers-log-reader-binding.yaml

envsubst < templates/view-binding.template.yaml > templates/substituted/view-binding.yaml
kubectl apply -f templates/substituted/view-binding.yaml

export TEAM_NAMES='cmc probate divorce'

for TEAM_NAME in ${TEAM_NAMES}; do
  NAMESPACE_EXISTS=$(kubectl get namespaces -o=jsonpath="{range .items[?(@.metadata.name=='${TEAM_NAME}')]}{.metadata.name}{'\n'}{end}")

  if [ -z "${NAMESPACE_EXISTS}" ]; then 
    echo "${TEAM_NAME} namespace doesn't exist, creating"
    kubectl create namespace ${TEAM_NAME}

  else
    echo "${TEAM_NAME} namespace exists, skipping create"
  fi 

  echo "Adding view binding for team: ${TEAM_NAME}"
  export TEAM_NAME=${TEAM_NAME}
  export TEAM_GROUP=$(az ad group list --query  "[?displayName=='${TEAM_NAME}-developers'].objectId" -o tsv)
  envsubst < templates/view-binding-team.template.yaml > templates/substituted/view-binding-${TEAM_NAME}.yaml
  kubectl apply -f templates/substituted/view-binding-${TEAM_NAME}.yaml

  if [ "${DEVELOPERS_EDIT_TEAM_SCOPED}" == "true" ]; then
    echo "Developers edit access at ${TEAM_NAME} namespace enabled"
    envsubst < templates/edit-binding-team.template.yaml > templates/substituted/edit-binding-${TEAM_NAME}.yaml
    kubectl apply -f templates/substituted/edit-binding-${TEAM_NAME}.yaml
  fi
done

if [ "${DEVELOPERS_EDIT_GLOBAL_SCOPED}" == "true" ]; then
    echo "Developers edit access at global namespace enabled"
    envsubst < templates/developers-edit-binding.template.yaml > templates/substituted/developers-edit-binding.yaml
    kubectl apply -f templates/substituted/developers-edit-binding.yaml
fi