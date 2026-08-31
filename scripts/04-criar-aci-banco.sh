#!/usr/bin/env bash
# =====================================================================
# Etapa 4 - ACI do BANCO de dados
#
# O volume do MySQL aponta para o file share da conta de armazenamento,
# garantindo a PERSISTENCIA exigida pelo checkpoint.
# As senhas viajam como secure-environment-variables (nao aparecem
# no portal nem em "az container show").
# =====================================================================
set -e

source "$(dirname "$0")/00-variaveis.sh"

: "${DB_ROOT_PASSWORD:?Exporte DB_ROOT_PASSWORD antes de rodar}"
: "${DB_PASSWORD:?Exporte DB_PASSWORD antes de rodar}"

ACR_SERVER=$(az acr show --name "${ACR_NAME}" --query loginServer --output tsv)
ACR_USER=$(az acr credential show --name "${ACR_NAME}" --query username --output tsv)
ACR_PASS=$(az acr credential show --name "${ACR_NAME}" --query "passwords[0].value" --output tsv)

STORAGE_KEY=$(az storage account keys list \
    --resource-group "${RG}" \
    --account-name "${STORAGE_NAME}" \
    --query "[0].value" \
    --output tsv)

echo ">>> Criando o ACI do banco: ${ACI_DB}"
az container create \
    --resource-group "${RG}" \
    --name "${ACI_DB}" \
    --image "${ACR_SERVER}/${IMG_DB}" \
    --registry-login-server "${ACR_SERVER}" \
    --registry-username "${ACR_USER}" \
    --registry-password "${ACR_PASS}" \
    --cpu 1 \
    --memory 1.5 \
    --os-type Linux \
    --ip-address Public \
    --ports 3306 \
    --dns-name-label "${DNS_DB}" \
    --environment-variables \
        MYSQL_DATABASE="${DB_NAME}" \
        MYSQL_USER="${DB_USER}" \
    --secure-environment-variables \
        MYSQL_ROOT_PASSWORD="${DB_ROOT_PASSWORD}" \
        MYSQL_PASSWORD="${DB_PASSWORD}" \
    --azure-file-volume-account-name "${STORAGE_NAME}" \
    --azure-file-volume-account-key "${STORAGE_KEY}" \
    --azure-file-volume-share-name "${SHARE_NAME}" \
    --azure-file-volume-mount-path /var/lib/mysql

echo ">>> Aguardando o banco ficar disponivel..."
az container show \
    --resource-group "${RG}" \
    --name "${ACI_DB}" \
    --query "{estado:instanceView.state, fqdn:ipAddress.fqdn, ip:ipAddress.ip}" \
    --output table
