#!/usr/bin/env bash
# =====================================================================
# Etapa 6 - Roteiro de testes do CRUD em nuvem
#
# Cada operacao da API e seguida de um SELECT direto no banco,
# que e a evidencia exigida pelo checkpoint.
#
# O script pausa entre as etapas para dar tempo de explicar no video.
# =====================================================================
set -e

source "$(dirname "$0")/00-variaveis.sh"

: "${DB_PASSWORD:?Exporte DB_PASSWORD antes de rodar}"

APP_FQDN=$(az container show --resource-group "${RG}" --name "${ACI_APP}" \
    --query ipAddress.fqdn --output tsv)

DB_FQDN=$(az container show --resource-group "${RG}" --name "${ACI_DB}" \
    --query ipAddress.fqdn --output tsv)

API="http://${APP_FQDN}:8080/clientes"
RAIZ="$(dirname "$0")/.."

selecionar() {
    echo
    echo "--- SELECT no banco (evidencia) -------------------------------"
    mysql -h "${DB_FQDN}" -P "${DB_PORT}" -u "${DB_USER}" -p"${DB_PASSWORD}" \
        -D "${DB_NAME}" -e "SELECT * FROM cliente;"
    echo "---------------------------------------------------------------"
    echo
    read -r -p "Pressione ENTER para a proxima operacao..."
}

echo "==============================================================="
echo " API: ${API}"
echo " BANCO: ${DB_FQDN}"
echo "==============================================================="
read -r -p "Pressione ENTER para comecar..."

echo
echo ">>> 1) GET - estado inicial da tabela"
curl -s "${API}" | python3 -m json.tool
selecionar

echo ">>> 2) POST - inserindo um novo cliente"
curl -s -X POST "${API}" \
    -H "Content-Type: application/json" \
    -d @"${RAIZ}/json/cliente-post.json" | python3 -m json.tool
selecionar

echo ">>> 3) PUT - alterando o cliente de id 3"
curl -s -X PUT "${API}/3" \
    -H "Content-Type: application/json" \
    -d @"${RAIZ}/json/cliente-put.json" | python3 -m json.tool
selecionar

echo ">>> 4) DELETE - removendo o cliente de id 3"
curl -s -o /dev/null -w "HTTP %{http_code}\n" -X DELETE "${API}/3"
selecionar

echo ">>> Testes concluidos."
