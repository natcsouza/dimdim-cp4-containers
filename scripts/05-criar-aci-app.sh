#!/usr/bin/env bash
# =====================================================================
# Etapa 5 - ACI da APLICACAO
#
# O app recebe o endereco do banco (FQDN do ACI do banco) por
# variavel de ambiente. Nenhuma credencial fica no codigo fonte.
# =====================================================================
set -e

source "$(dirname "$0")/00-variaveis.sh"

: "${DB_PASSWORD:?Exporte DB_PASSWORD antes de rodar}"

ACR_SERVER=$(az acr show --name "${ACR_NAME}" --query loginServer --output tsv)
ACR_USER=$(az acr credential show --name "${ACR_NAME}" --query username --output tsv)
ACR_PASS=$(az acr credential show --name "${ACR_NAME}" --query "passwords[0].value" --output tsv)

DB_FQDN=$(az container show \
    --resource-group "${RG}" \
    --name "${ACI_DB}" \
    --query ipAddress.fqdn \
    --output tsv)

echo ">>> Banco encontrado em ${DB_FQDN}"

echo ">>> Criando o ACI da aplicacao: ${ACI_APP}"
az container create \
    --resource-group "${RG}" \
    --name "${ACI_APP}" \
    --image "${ACR_SERVER}/${IMG_APP}" \
    --registry-login-server "${ACR_SERVER}" \
    --registry-username "${ACR_USER}" \
    --registry-password "${ACR_PASS}" \
    --cpu 1 \
    --memory 1.5 \
    --os-type Linux \
    --ip-address Public \
    --ports 8080 \
    --dns-name-label "${DNS_APP}" \
    --environment-variables \
        DB_HOST="${DB_FQDN}" \
        DB_PORT="${DB_PORT}" \
        DB_NAME="${DB_NAME}" \
        DB_USER="${DB_USER}" \
    --secure-environment-variables \
        DB_PASSWORD="${DB_PASSWORD}"

echo ">>> Aplicacao publicada. Endereco:"
APP_FQDN=$(az container show \
    --resource-group "${RG}" \
    --name "${ACI_APP}" \
    --query ipAddress.fqdn \
    --output tsv)

echo "    http://${APP_FQDN}:8080/clientes"
