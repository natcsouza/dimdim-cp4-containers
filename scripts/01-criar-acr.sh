#!/usr/bin/env bash
# =====================================================================
# Etapa 1 - Grupo de recursos + Azure Container Registry (ACR)
# =====================================================================
set -e

source "$(dirname "$0")/00-variaveis.sh"

echo ">>> Criando o grupo de recursos ${RG}"
az group create \
    --name "${RG}" \
    --location "${LOCATION}"

echo ">>> Criando o Azure Container Registry ${ACR_NAME}"
az acr create \
    --resource-group "${RG}" \
    --name "${ACR_NAME}" \
    --sku Basic \
    --admin-enabled true

echo ">>> Autenticando o Docker local no ACR"
az acr login --name "${ACR_NAME}"

echo ">>> ACR criado. Servidor de login:"
az acr show \
    --name "${ACR_NAME}" \
    --query loginServer \
    --output tsv
