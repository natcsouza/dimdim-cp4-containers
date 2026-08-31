# FIAP — Tecnologia em Desenvolvimento de Sistemas

## DevOps Tools & Cloud Computing
### 1º Checkpoint — 2º Semestre — Containers em Nuvem (ACR / ACI)

**Professor:** João Carlos Menk

---

## Grupo: _[NOME DO GRUPO]_

| RM | Nome completo |
|---|---|
| _[RM]_ | _[Nome]_ |
| _[RM]_ | _[Nome]_ |
| _[RM]_ | _[Nome]_ |
| _[RM]_ | _[Nome]_ |

**Representante do grupo:** _[Nome]_ — RM _[RM]_

---

## Links

**Repositório GitHub:**
_[https://github.com/.../dimdim-containers]_

**Vídeo de demonstração:**
_[link]_

---

## Recursos criados na Azure

| Recurso | Nome |
|---|---|
| Grupo de recursos | `rg-[RM]-dimdim` |
| Container Registry | `acr[RM]dimdim` |
| Conta de Armazenamento | `st[RM]dimdim` |
| File Share | `dimdim-mysql` |
| ACI — Banco de dados | `aci-[RM]-dimdim-db` |
| ACI — Aplicação | `aci-[RM]-dimdim-app` |

## Imagens registradas no ACR

| Imagem | Conteúdo |
|---|---|
| `[RM]-dimdim-db:1.0` | MySQL 8.0 com o DDL do projeto |
| `[RM]-dimdim-app:1.0` | API Spring Boot (usuário não-root) |

---

## Solução entregue

Aplicação Java (Spring Boot 3 + JPA) expondo uma API REST com CRUD completo sobre a
tabela `cliente`, e banco MySQL 8.0, ambos conteinerizados e publicados no Azure
Container Registry. Os dois containers rodam como Azure Container Instances, com os
dados do banco persistidos em um Azure File Share da Conta de Armazenamento.

Todos os recursos foram criados via Azure CLI; os scripts estão no repositório, em
`scripts/`, junto com os Dockerfiles, o DDL das tabelas (`db/init/01-ddl.sql`), os
arquivos JSON de teste (`json/`) e o README com o tutorial de execução.
