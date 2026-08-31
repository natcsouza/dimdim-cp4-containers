#!/usr/bin/env bash
# =====================================================================
# GRAVAR O VIDEO — modo teleprompter
#
# Como usar:
#   1. Comece a gravar a tela
#   2. Rode:  bash gravar-video.sh
#   3. Leia em voz alta o que aparecer em amarelo
#   4. Aperte ENTER
#   5. Repita ate acabar
#
# Nao precisa decorar nada. So ler e apertar ENTER.
# =====================================================================

export AZURE_CONFIG_DIR="${AZURE_CONFIG_DIR:-$HOME/.azure-natalia}"

RG="rg-564099-dimdim"
ACR="acr564099dimdim"
ACI_DB="aci-564099-dimdim-db"
ACI_APP="aci-564099-dimdim-app"
DB_HOST="564099-dimdim-db.eastus2.azurecontainer.io"
API="http://564099-dimdim-app.eastus2.azurecontainer.io:8080/clientes"

AMARELO=$'\e[1;33m'
VERDE=$'\e[1;32m'
CINZA=$'\e[0;90m'
FIM=$'\e[0m'

PASSO=0
TOTAL=10

# Roda um SELECT no banco em nuvem. No Azure Cloud Shell o cliente mysql ja
# vem instalado; num computador com Docker, usa o cliente dentro de um
# container. Assim o mesmo script serve nos dois lugares.
if command -v mysql >/dev/null 2>&1; then
    sql() {
        mysql -h "$DB_HOST" -u dimdim -p"$DB_PASSWORD" -D dimdim \
            -e "$1" 2>&1 | grep -v "Using a password"
    }
else
    sql() {
        docker run --rm mysql:8.0 mysql \
            -h "$DB_HOST" -u dimdim -p"$DB_PASSWORD" -D dimdim \
            -e "$1" 2>&1 | grep -v "Using a password"
    }
fi

falar() {
    PASSO=$((PASSO + 1))
    clear
    echo
    echo "${CINZA}────────────────────────  PASSO $PASSO de $TOTAL  ────────────────────────${FIM}"
    echo
    echo "${AMARELO}  FALE ISSO:${FIM}"
    echo
    # imprime cada linha da fala com recuo
    while IFS= read -r linha; do
        echo "${AMARELO}    $linha${FIM}"
    done <<< "$1"
    echo
    echo "${CINZA}────────────────────────────────────────────────────────────────${FIM}"
    echo
    read -r -p "  Leu? Aperte ENTER para rodar o comando... "
    echo
}

fim_do_passo() {
    echo
    echo "${VERDE}  ✓ pronto${FIM}"
    echo
    read -r -p "  Aperte ENTER para o proximo passo... "
}

# =====================================================================

clear
echo
echo "${VERDE}  CONFERINDO SE ESTA TUDO PRONTO${FIM}"
echo

problema=0

if [ -z "$DB_PASSWORD" ]; then
    echo "  ${AMARELO}x  A senha do banco nao foi definida.${FIM}"
    echo "     Rode isto ANTES de comecar a gravar (a senha nao pode aparecer no video):"
    echo "     ${CINZA}export DB_PASSWORD='a-senha-do-banco'${FIM}"
    problema=1
else
    echo "  ${VERDE}v${FIM}  senha do banco definida"
fi

if command -v mysql >/dev/null 2>&1; then
    echo "  ${VERDE}v${FIM}  cliente mysql encontrado"
elif command -v docker >/dev/null 2>&1; then
    echo "  ${VERDE}v${FIM}  docker encontrado (sera usado para o mysql)"
else
    echo "  ${AMARELO}x  Nao achei nem o mysql nem o docker.${FIM}"
    echo "     Use o Azure Cloud Shell, que ja vem com o mysql instalado."
    problema=1
fi

if az account show >/dev/null 2>&1; then
    conta=$(az account show --query user.name -o tsv 2>/dev/null)
    echo "  ${VERDE}v${FIM}  Azure conectada como ${conta}"
else
    echo "  ${AMARELO}x  A Azure nao esta conectada. Rode: az login${FIM}"
    problema=1
fi

if curl -s -m 20 -o /dev/null "$API"; then
    echo "  ${VERDE}v${FIM}  a aplicacao esta respondendo"
else
    echo "  ${AMARELO}x  A aplicacao nao respondeu. Confira se o container esta ligado.${FIM}"
    problema=1
fi

echo
if [ "$problema" = "1" ]; then
    echo "  ${AMARELO}Resolva os itens marcados acima antes de gravar.${FIM}"
    echo
    exit 1
fi

echo "${VERDE}  Tudo certo. Agora:${FIM}"
echo
echo "    1. A gravacao de tela ja esta rodando?"
echo "    2. O microfone esta ligado?"
echo "    3. O portal da Azure esta aberto numa aba?"
echo
read -r -p "  Se sim, aperte ENTER. "

# ---------------------------------------------------------------------
falar "Oi professor. Sou a Natalia, RM 564099.
Esse e o checkpoint de containers em nuvem, o projeto DimDim.
Vou comecar mostrando os recursos que eu criei na Azure."

az group show --name "$RG" --query "{grupo:name, regiao:location}" --output table
echo
az resource list --resource-group "$RG" --query "[].{recurso:name, tipo:type}" --output table
fim_do_passo

# ---------------------------------------------------------------------
falar "Sao quatro recursos: o Container Registry, a conta de armazenamento,
e as duas instancias de container, uma do banco e uma da aplicacao."

az container list --resource-group "$RG" \
    --query "[].{container:name, estado:instanceView.state, endereco:ipAddress.fqdn}" \
    --output table
fim_do_passo

# ---------------------------------------------------------------------
falar "Aqui estao as duas imagens que eu registrei no Container Registry.
Repare que as duas comecam com o meu RM, como o enunciado pediu."

az acr repository list --name "$ACR" --output table
fim_do_passo

# ---------------------------------------------------------------------
falar "O container da aplicacao nao roda como root.
Ele roda com um usuario que eu criei no Dockerfile, chamado dimdim."

az container exec --resource-group "$RG" --name "$ACI_APP" --exec-command "id"
fim_do_passo

# ---------------------------------------------------------------------
falar "Agora o CRUD. Primeiro o estado inicial: dois clientes na tabela."

echo "${CINZA}--- pela API ---${FIM}"
curl -s "$API" | python3 -m json.tool
echo
echo "${CINZA}--- direto no banco ---${FIM}"
sql "SELECT * FROM cliente;"
fim_do_passo

# ---------------------------------------------------------------------
falar "Agora eu vou inserir um cliente novo. Isso e o CREATE."

RESPOSTA=$(curl -s -X POST "$API" -H "Content-Type: application/json" \
    -d @"$(dirname "$0")/json/cliente-post.json")
echo "$RESPOSTA" | python3 -m json.tool

# Guarda o id que a API devolveu: o AUTO_INCREMENT do MySQL nao volta,
# entao nao da para presumir que sera sempre 3.
NOVO_ID=$(echo "$RESPOSTA" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")

echo
echo "${CINZA}--- conferindo no banco ---${FIM}"
sql "SELECT * FROM cliente;"
fim_do_passo

# ---------------------------------------------------------------------
falar "O cliente novo apareceu no banco.
Agora o READ: buscando esse cliente pela API."

curl -s "$API/$NOVO_ID" | python3 -m json.tool
fim_do_passo

# ---------------------------------------------------------------------
falar "Agora o UPDATE. Vou mudar o e-mail e o saldo desse cliente."

curl -s -X PUT "$API/$NOVO_ID" -H "Content-Type: application/json" \
    -d @"$(dirname "$0")/json/cliente-put.json" | python3 -m json.tool
echo
echo "${CINZA}--- conferindo no banco ---${FIM}"
sql "SELECT * FROM cliente;"
fim_do_passo

# ---------------------------------------------------------------------
falar "O e-mail e o saldo mudaram no banco.
Agora o DELETE, removendo esse cliente."

curl -s -o /dev/null -w "resposta da API: HTTP %{http_code}\n" -X DELETE "$API/$NOVO_ID"
echo
echo "${CINZA}--- conferindo no banco ---${FIM}"
sql "SELECT * FROM cliente;"
fim_do_passo

# ---------------------------------------------------------------------
falar "O registro sumiu da tabela. Os quatro comandos do CRUD funcionaram,
e cada um foi confirmado com um SELECT direto no banco.
Todos os recursos foram criados por linha de comando, e os scripts
estao no GitHub junto com os Dockerfiles e o DDL das tabelas.
Obrigada, professor."

echo
echo "${VERDE}  ============================================${FIM}"
echo "${VERDE}    ACABOU. Pode parar a gravacao.${FIM}"
echo "${VERDE}  ============================================${FIM}"
echo
