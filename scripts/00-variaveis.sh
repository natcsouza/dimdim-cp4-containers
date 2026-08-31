#!/usr/bin/env bash
# =====================================================================
# Projeto DimDim - variaveis usadas por todos os scripts
#
# Use:  source scripts/00-variaveis.sh
#
# ATENCAO: as senhas NAO ficam aqui. Exporte antes de rodar os scripts:
#   export DB_ROOT_PASSWORD='...'
#   export DB_PASSWORD='...'
# =====================================================================

# --- Identificacao do grupo -------------------------------------------------
export RM="RM_DO_REPRESENTANTE"          # <<< TROCAR pelo RM do representante
export GRUPO="dimdim"

# --- Recursos Azure ---------------------------------------------------------
export RG="rg-${RM}-dimdim"
export LOCATION="brazilsouth"

export ACR_NAME="acr${RM}dimdim"          # so letras minusculas e numeros
export STORAGE_NAME="st${RM}dimdim"       # so letras minusculas e numeros
export SHARE_NAME="dimdim-mysql"

export ACI_DB="aci-${RM}-dimdim-db"
export ACI_APP="aci-${RM}-dimdim-app"

export DNS_DB="${RM}-dimdim-db"
export DNS_APP="${RM}-dimdim-app"

# --- Imagens ----------------------------------------------------------------
export IMG_DB="${RM}-dimdim-db:1.0"
export IMG_APP="${RM}-dimdim-app:1.0"

# --- Banco ------------------------------------------------------------------
export DB_NAME="dimdim"
export DB_USER="dimdim"
export DB_PORT="3306"

echo "Variaveis carregadas para o RM ${RM} no grupo de recursos ${RG}"
