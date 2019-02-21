#!/bin/bash
set -e

KEY_VAULT=${1}
CERTIFICATE_NAME=${2}
KUBERNETES_SECRET_NAME=${3}
KUBERNETES_NAMESPACE=${4}

function usage() {
  echo "usage: ./create-kube-secret-from-keyvault.sh <keyvault-name> <certificate-name> <kube-secret-name> <kube-namespace-name>" 
}

if [ -z "${KEY_VAULT}" ] || [ -z "${CERTIFICATE_NAME}" ] || [ -z "${KUBERNETES_SECRET_NAME}" ] || [ -z "${KUBERNETES_NAMESPACE}" ]
then
  usage
  exit 1
fi

TMP_DIR=$(mktemp -d)

cd ${TMP_DIR}
az keyvault secret show --vault-name ${KEY_VAULT} --name ${CERTIFICATE_NAME} --query value -o tsv | \
  base64 -D > ${CERTIFICATE_NAME}.pfx

openssl pkcs12 -in ${CERTIFICATE_NAME}.pfx -out ${CERTIFICATE_NAME}.pem -nodes -passin pass:""
openssl pkey -in ${CERTIFICATE_NAME}.pem -out ${CERTIFICATE_NAME}.key

kubectl -n ${KUBERNETES_NAMESPACE} create secret tls ${KUBERNETES_SECRET_NAME} --key ${CERTIFICATE_NAME}.key --cert ${CERTIFICATE_NAME}.pem

rm -rf ${TMP_DIR}