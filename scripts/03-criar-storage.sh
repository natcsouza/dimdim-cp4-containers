#!/usr/bin/env bash
# =====================================================================
# Etapa 3 - Conta de Armazenamento + File Share
#
# O File Share e montado no container do banco para que os dados
# PERSISTAM mesmo que o ACI seja reiniciado ou recriado.
# =====================================================================
set -e

source "$(dirname "$0")/00-variaveis.sh"

echo ">>> Criando a conta de armazenamento ${STORAGE_NAME}"
az storage account create \
    --resource-group "${RG}" \
    --name "${STORAGE_NAME}" \
    --location "${LOCATION}" \
    --sku Standard_LRS

echo ">>> Obtendo a chave da conta de armazenamento"
STORAGE_KEY=$(az storage account keys list \
    --resource-group "${RG}" \
    --account-name "${STORAGE_NAME}" \
    --query "[0].value" \
    --output tsv)

echo ">>> Criando o file share ${SHARE_NAME}"
az storage share create \
    --name "${SHARE_NAME}" \
    --account-name "${STORAGE_NAME}" \
    --account-key "${STORAGE_KEY}"

echo ">>> File share criado. Compartilhamentos existentes:"
az storage share list \
    --account-name "${STORAGE_NAME}" \
    --account-key "${STORAGE_KEY}" \
    --output table
