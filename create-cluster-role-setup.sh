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

export CLUSTER_ADMIN_GROUP=$(az ad group create  --display-name ${BASE_NAME}-cluster-admins --mail-nickname ${BASE_NAME}-cluster-admins --query objectId -o tsv)

az aks get-credentials --resource-group ${BASE_NAME} --name ${BASE_NAME} --admin

mkdir -p templates/substituted

envsubst < templates/cluster-admin-binding.template.yaml > templates/substituted/cluster-admin-binding.yaml
kubectl apply -f templates/substituted/cluster-admin-binding.yaml

envsubst < templates/developers-log-reader-binding.template.yaml > templates/substituted/developers-log-reader-binding.yaml
kubectl apply -f templates/substituted/developers-log-reader-binding.yaml