# Guia rápido — Checkpoint de Containers em Nuvem

Leia isso antes de gravar. São 5 minutos.

---

## 1. O que a gente construiu, em 6 frases

**Docker** — empacota um programa junto com tudo que ele precisa pra rodar.
O pacote se chama **imagem**. Quando a imagem roda, vira um **container**.

**Dockerfile** — a receita da imagem. Diz o que instalar e como iniciar.

**ACR (Azure Container Registry)** — o lugar onde as imagens ficam guardadas
na Azure. É tipo um Google Drive, mas de imagens de container.

**ACI (Azure Container Instance)** — pega uma imagem do ACR e faz ela rodar
na nuvem, com um endereço público na internet.

**Conta de Armazenamento** — um disco na Azure. A gente montou ele dentro do
container do banco, então os dados ficam salvos lá fora, não dentro do container.

**Por que isso importa:** container é descartável. Se ele morrer, tudo que
estava dentro some. Por isso os dados do banco moram no disco de fora.

---

## 2. O desenho

```
        VOCE / PROFESSOR
              |
              | http://564099-dimdim-app...:8080/clientes
              v
    +---------------------+
    |   ACI da APLICACAO  |     Java + Spring Boot
    |   (roda como        |     Recebe os pedidos e responde
    |    usuario dimdim,  |
    |    nao root)        |
    +---------------------+
              |
              | pergunta pro banco
              v
    +---------------------+
    |   ACI do BANCO      |     MySQL 8
    |                     |
    +---------------------+
              |
              | grava os dados aqui fora
              v
    +---------------------+
    | CONTA DE ARMAZENAM. |     Se o container morrer,
    |  (file share)       |     os dados continuam aqui
    +---------------------+

    As duas imagens vieram do ACR (acr564099dimdim)
```

---

## 3. Nossos recursos

| O que é | Nome |
|---|---|
| Grupo de recursos | `rg-564099-dimdim` |
| Registry (guarda imagens) | `acr564099dimdim` |
| Armazenamento | `st564099dimdim` |
| Container do banco | `aci-564099-dimdim-db` |
| Container do app | `aci-564099-dimdim-app` |

Endereço da API: `http://564099-dimdim-app.eastus2.azurecontainer.io:8080/clientes`

A tabela é `cliente`, com: id, nome, cpf, email e saldo.

---

## 4. Como gravar o vídeo

**Antes:**
- fonte do terminal grande (Ctrl e + umas 3 vezes)
- fechar abas com coisa pessoal
- portal da Azure aberto numa aba
- microfone ligado, gravação em 720p ou mais

**Na hora:**

1. Começa a gravar
2. Roda: `bash gravar-video.sh`
3. Aparece um texto **amarelo** na tela. Lê ele em voz alta.
4. Aperta ENTER. O comando roda sozinho.
5. Aperta ENTER de novo pro próximo.
6. Repete até acabar (são 10 passos).

**Não precisa decorar nada.** O script mostra o que falar e roda o comando.

Se travar em algum passo: Ctrl+C, roda de novo. Pode repetir quantas vezes quiser.

---

## 5. O que o script vai mostrar, na ordem

| Passo | O que aparece |
|---|---|
| 1 | Os recursos criados na Azure |
| 2 | Os dois containers rodando |
| 3 | As duas imagens no ACR (com seu RM no nome) |
| 4 | Prova de que o app não roda como root |
| 5 | Estado inicial: 2 clientes |
| 6 | **CREATE** — insere cliente + SELECT no banco |
| 7 | **READ** — busca o cliente |
| 8 | **UPDATE** — muda e-mail e saldo + SELECT |
| 9 | **DELETE** — remove + SELECT mostrando que sumiu |
| 10 | Fechamento |

O SELECT depois de cada operação é o que mais vale nota (são 30 pontos).

---

## 6. Se o professor perguntar

**"Por que o app não pode rodar como root?"**
> Se alguém invadir o container, com root ele faz o que quiser lá dentro.
> Eu criei um usuário chamado `dimdim` no Dockerfile e usei o comando `USER`,
> então o processo roda sem privilégio de administrador.

**"E se o container do banco morrer, perde tudo?"**
> Não. Os dados ficam num file share da conta de armazenamento, montado em
> `/var/lib/mysql`. Eu testei: reiniciei o container e os dados continuaram lá.

**"Por que MySQL e não H2?"**
> O H2 é banco em memória e o enunciado não permite. Além disso ele não serviria
> aqui, porque eu precisava de um banco em container separado, com persistência.

**"O que é multi-stage no Dockerfile?"**
> São duas etapas. Na primeira eu uso a imagem do Maven pra compilar o Java.
> Na segunda eu copio só o `.jar` pronto pra uma imagem de JRE, que é bem menor.
> Assim a imagem final não carrega o Maven nem o código fonte.

**"Como o app sabe o endereço do banco?"**
> Por variável de ambiente. Quando eu crio o ACI do app, passo o endereço do
> banco e a senha. Nada disso está escrito no código.

**"Onde estão as senhas?"**
> Em lugar nenhum do código ou do GitHub. Elas entram como
> `--secure-environment-variables`, que nem aparecem no portal da Azure.

**"Por que East US 2 e não Brasil?"**
> A assinatura de estudante não libera a região do Brasil. Só permite
> canadacentral, southcentralus, chilecentral, eastus2 e northcentralus.

---

## 7. Checklist antes de entregar

- [ ] Vídeo em 720p, com sua voz, começando pelos recursos na Azure
- [ ] Os 4 comandos do CRUD, cada um com SELECT depois
- [ ] Código no GitHub (o professor precisa conseguir abrir)
- [ ] Link do vídeo com acesso liberado
- [ ] PDF `<nome_do_grupo>_container.pdf` com nome, RM, e os dois links
- [ ] Upload no Teams feito pelo representante do grupo

---

## 8. Depois que sair a nota

Apaga tudo pra não gastar seu crédito da Azure:

```bash
az group delete --name rg-564099-dimdim --yes
```

**Só depois da nota.** Antes disso o professor pode querer ver os recursos.
