#!/bin/bash
cd -P -- "$(dirname -- "$0")"

export BASE_NAME=${1}

function usage() {
  echo "usage: ./setup-app-gateway-ingress.sh <base-name>"
}

if [ -z "${BASE_NAME}" ]
then
    usage
    exit 1
fi

helm repo add application-gateway-kubernetes-ingress https://azure.github.io/application-gateway-kubernetes-ingress/helm/
helm repo update

export NODE_RESOURCE_GROUP=$(az aks show -g core-infra-${BASE_NAME} --name ${BASE_NAME} --query nodeResourceGroup -o tsv)
export API_SERVER_ADDRESS=$(az aks show -g core-infra-${BASE_NAME} --name ${BASE_NAME}  --query fqdn -o tsv)

export SUBSCRIPTION_ID=$(az account show --query id -o tsv)

export IDENTITY_CLIENT_ID=$(az identity show -g ${NODE_RESOURCE_GROUP}  --name ${BASE_NAME} --query clientId -o tsv)

envsubst < templates/helm-config.template.yaml > templates/substituted/helm-config.yaml
envsubst < templates/ingress-identity-binding.template.yaml > templates/substituted/ingress-identity-binding.yaml

kubectl apply -f templates/substituted/ingress-identity-binding.yaml

export IDENTITY_CLIENT_ID=$(az identity show -g ${NODE_RESOURCE_GROUP} -n ${BASE_NAME} --query clientId -o tsv)
# needs: Microsoft.Network/applicationGateways/write
az role assignment create --role "Network Contributor" --assignee ${IDENTITY_CLIENT_ID} --scope /subscriptions/${SUBSCRIPTION_ID}/resourcegroups/${NODE_RESOURCE_GROUP}

az group deployment create --name ag -g ${NODE_RESOURCE_GROUP}  --template-file app-gateway.json

helm install -f templates/substituted/helm-config.yaml  --namespace ag-poc application-gateway-kubernetes-ingress/ingress-azure --name app-gw-ingress
