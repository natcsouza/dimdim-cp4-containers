# Roteiro do vídeo — Checkpoint Containers em Nuvem

**Regras que o vídeo precisa cumprir** (cada uma vale desconto se faltar):

- mínimo 720p, áudio claro, **explicação por voz** (−30 se não)
- **começar** mostrando os recursos criados na Azure (−30 se não)
- demonstração **individual e detalhada** de cada operação do CRUD, com **SELECT no
  banco** depois de cada uma (−30 se não)

Duração alvo: **8 a 12 minutos**. Sem pressa nos SELECTs — é neles que está a nota.

Antes de gravar:
- fechar abas e janelas com informação pessoal
- terminal com fonte grande (Ctrl + `+` umas 3 vezes)
- ter as senhas já exportadas no terminal, para não digitá-las na tela
- `export DB_ROOT_PASSWORD=... ; export DB_PASSWORD=...`

---

## Bloco 1 — Abertura (1 min)

**Mostrar:** portal da Azure, dentro do grupo de recursos.

> "Oi, professor. Sou a Natália, RM [RM], do grupo [GRUPO]. Este é o checkpoint de
> containers em nuvem do projeto DimDim. Começo mostrando os recursos que eu criei
> na Azure: este é o grupo de recursos [rg-...], e dentro dele eu tenho quatro
> recursos — o Container Registry, a conta de armazenamento, e as duas instâncias de
> container: uma do banco de dados e uma da aplicação."

Passar o mouse por cada recurso enquanto fala o nome. **Não corra.**

---

## Bloco 2 — As imagens no ACR (1 min)

**Mostrar:** o ACR no portal → Repositories. Depois, no terminal:

```bash
az acr repository list --name <acr> --output table
az acr repository show-tags --name <acr> --repository <RM>-dimdim-app --output table
```

> "Aqui estão as duas imagens que eu registrei: uma do banco e uma da aplicação.
> Repare que as duas levam o meu RM como prefixo, como o enunciado pediu."

---

## Bloco 3 — Os Dockerfiles (1,5 min)

**Mostrar:** `app/Dockerfile` no editor.

> "Este é o Dockerfile da aplicação. Ele é multi-stage: na primeira etapa eu uso a
> imagem do Maven para compilar o projeto Java, e na segunda eu copio só o .jar para
> uma imagem de JRE, que é bem menor.
> E este trecho aqui é importante: eu crio um usuário chamado `dimdim` e uso o
> comando USER, porque o container da aplicação não pode rodar como root."

Provar ao vivo:

```bash
az container exec --resource-group <rg> --name aci-<RM>-dimdim-app --exec-command "id"
```

> "Está rodando com o uid 100, usuário dimdim — sem privilégio administrativo."

Depois `db/Dockerfile` e o DDL:

> "O Dockerfile do banco parte do MySQL 8 e copia o script de DDL para a pasta de
> inicialização, então a tabela é criada sozinha quando o banco sobe pela primeira vez."

---

## Bloco 4 — A persistência (1,5 min)

**Mostrar:** conta de armazenamento no portal → File shares → o share.

> "Os dados do MySQL não ficam dentro do container. Eu montei este file share da conta
> de armazenamento na pasta /var/lib/mysql do container do banco. Se o container for
> reiniciado ou recriado, os dados continuam aqui."

Prova ao vivo (**faça isso, é o que convence**):

```bash
az container restart --resource-group <rg> --name aci-<RM>-dimdim-db
# esperar voltar, depois:
mysql -h <fqdn-banco> -u dimdim -p -D dimdim -e "SELECT * FROM cliente;"
```

> "Reiniciei o container do banco e os dados continuam lá."

---

## Bloco 5 — O CRUD, operação por operação (4 a 5 min)

Este é o bloco que mais vale nota. **Uma operação de cada vez, com SELECT depois de
cada uma.** Use `bash scripts/06-testes-crud.sh`, que já pausa entre as etapas.

### 5.1 — Estado inicial

```bash
curl http://<fqdn-app>:8080/clientes
mysql -h <fqdn-banco> -u dimdim -p -D dimdim -e "SELECT * FROM cliente;"
```

> "Começo mostrando o estado inicial: dois clientes, tanto pela API quanto direto no
> banco."

### 5.2 — CREATE (POST)

```bash
curl -X POST http://<fqdn-app>:8080/clientes \
     -H "Content-Type: application/json" \
     -d @json/cliente-post.json
```

> "Agora eu insiro um cliente novo. A API respondeu 201 com o id 3."

```bash
mysql -h <fqdn-banco> -u dimdim -p -D dimdim -e "SELECT * FROM cliente;"
```

> "E aqui, direto no banco, a linha com id 3 apareceu. Este é o CREATE persistido."

### 5.3 — READ (GET)

```bash
curl http://<fqdn-app>:8080/clientes/3
```

> "O GET por id devolve exatamente o registro que acabou de ser gravado."

### 5.4 — UPDATE (PUT)

```bash
curl -X PUT http://<fqdn-app>:8080/clientes/3 \
     -H "Content-Type: application/json" \
     -d @json/cliente-put.json
```

> "No update eu mudei o e-mail e o saldo."

```bash
mysql -h <fqdn-banco> -u dimdim -p -D dimdim -e "SELECT * FROM cliente;"
```

> "No banco, o e-mail mudou de dimdim.com.br para fiap.com.br e o saldo foi de
> 8.750 para 12.300. UPDATE confirmado."

### 5.5 — DELETE

```bash
curl -i -X DELETE http://<fqdn-app>:8080/clientes/3
```

> "O delete respondeu 204."

```bash
mysql -h <fqdn-banco> -u dimdim -p -D dimdim -e "SELECT * FROM cliente;"
```

> "E o registro de id 3 sumiu da tabela. Sobraram só os dois iniciais."

---

## Bloco 6 — Fechamento (30 s)

**Mostrar:** o repositório no GitHub.

> "Todos os recursos foram criados por Azure CLI — os scripts estão nesta pasta do
> repositório, junto com os Dockerfiles, o DDL das tabelas, os JSONs de teste e o
> README com o passo a passo. Obrigada, professor."

---

## Checklist antes de enviar

- [ ] Vídeo em 720p ou mais
- [ ] Áudio audível do começo ao fim
- [ ] Abre mostrando os recursos na Azure
- [ ] Os 4 verbos demonstrados, cada um com SELECT depois
- [ ] Aparece a prova de que o app não roda como root
- [ ] Nenhuma senha visível na tela
- [ ] Link do vídeo com permissão de acesso liberada (professor sem acesso = zero)
- [ ] Repositório público ou com o professor convidado
- [ ] PDF `<nome_grupo>_container.pdf` com folha de rosto, links do GitHub e do vídeo
- [ ] Upload no Teams feito **pelo representante**
