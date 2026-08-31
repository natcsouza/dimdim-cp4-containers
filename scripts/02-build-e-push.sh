#!/usr/bin/env bash
# =====================================================================
# Etapa 2 - Build local das imagens e push para o ACR
#
# O nome das imagens leva o RM do representante como prefixo,
# conforme exigido pelo checkpoint.
# =====================================================================
set -e

source "$(dirname "$0")/00-variaveis.sh"

RAIZ="$(dirname "$0")/.."

ACR_SERVER=$(az acr show --name "${ACR_NAME}" --query loginServer --output tsv)

echo ">>> Build da imagem do BANCO"
docker build -t "${IMG_DB}" "${RAIZ}/db"

echo ">>> Build da imagem do APP"
docker build -t "${IMG_APP}" "${RAIZ}/app"

echo ">>> Marcando as imagens com o endereco do ACR"
docker tag "${IMG_DB}"  "${ACR_SERVER}/${IMG_DB}"
docker tag "${IMG_APP}" "${ACR_SERVER}/${IMG_APP}"

echo ">>> Enviando as imagens para o ACR"
docker push "${ACR_SERVER}/${IMG_DB}"
docker push "${ACR_SERVER}/${IMG_APP}"

echo ">>> Imagens registradas no ACR:"
az acr repository list \
    --name "${ACR_NAME}" \
    --output table
