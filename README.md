# Publicar seu app no ar

Solicite ao prof. Alex Orozco um namespace.

Seu app será hospedado em `https://<seu-namespace>.projetos.sapucaia.ifsul.edu.br` sem
configurar servidor. Serve para qualquer repositório seu, novo ou já existente.

## 1. Adicione este arquivo ao seu repositório

`.github/workflows/deploy.yml`:

```yaml
name: Deploy

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy:
    permissions:
      contents: read
      packages: write
    uses: ss-cstads/deploy-apps/.github/workflows/deploy.yml@v2
    secrets:
      NOMAD_TOKEN: ${{ secrets.NOMAD_TOKEN }}
      APP_ENV: ${{ secrets.APP_ENV }}
```

**O Dockerfile é opcional.** O pipeline constrói o app de um de dois jeitos:

- **sem `Dockerfile`** (o mais simples): ele reconhece o projeto pelos arquivos;
- **com `Dockerfile`**: se existir um na pasta do app, é ele que vale.

Sem `Dockerfile`, o repositório precisa ter:

| Projeto | O que o repositório precisa ter |
|---------|--------------------------------|
| Node.js | `package.json` com o script `start`; o app escuta em `process.env.PORT` |
| Python | `requirements.txt` e um arquivo `Procfile`, por exemplo: `web: gunicorn app:app --bind 0.0.0.0:$PORT` |
| Java | `pom.xml` ou `build.gradle`, e **memória no `with:`**: `memory: 768`, ou `memory: 512` com um `project.toml` como [este](exemplos/fullstack-java/backend/project.toml) (o padrão de 256 MB não basta para a JVM). Usa Java 21, a menos que o `project.toml` peça outra versão ([exemplo](exemplos/api-java-mobile/project.toml)) |
| PHP | `index.php` na raiz; extensões (MySQL etc.) em `.php.ini.d/` ([exemplo](exemplos/php)) |
| Go | `go.mod` (até Go 1.26) |
| Site estático | `index.html` na raiz |
| .NET, Ruby | os arquivos normais do projeto |

Com `Dockerfile` ([modelos por linguagem](exemplos/dockerfiles)), você controla a
imagem inteira; use quando o app precisa de algo que a detecção automática não
faz (um `nginx.conf` próprio, um pacote do sistema, uma versão específica).
Informe a porta do app com a opção `port` (veja [Opções](#opções): onde ela fica
e como escrever).

## 2. Cadastre o seu token

No repositório: **Settings → Secrets and variables → Actions → New repository secret**.
Nome: `NOMAD_TOKEN`. Valor: o token da folha de credenciais que você recebeu.

## 3. Faça push

Acompanhe na aba **Actions**. Em cerca de 2 minutos o app está no ar. O repositório
precisa ser **público**.

## Opções

As opções vão no **fim do arquivo `.github/workflows/deploy.yml`** do seu
repositório (o do passo 1), num bloco `with:` alinhado com `secrets:`. O fim do
arquivo fica assim:

```yaml
    uses: ss-cstads/deploy-apps/.github/workflows/deploy.yml@v2
    secrets:
      NOMAD_TOKEN: ${{ secrets.NOMAD_TOKEN }}
      APP_ENV: ${{ secrets.APP_ENV }}
    with:
      port: 3000
      database: true
```

Só existe um bloco `with:`; ponha nele todas as opções que for usar:

| Opção | Padrão | Para que serve |
|-------|--------|----------------|
| `port` | `8080` | porta do app (sem Dockerfile, o app recebe a variável `PORT` com esse valor) |
| `health` | `/` | rota que responde 200 quando o app está funcionando |
| `memory` | `256` | memória em MB (Java: no mínimo `512`, veja a tabela do passo 1) |
| `database` | `false` | `true` cria um MySQL; o app recebe `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD` e `DATABASE_URL` |

### App em subpastas (frontend + backend)

Se o repositório tem o site numa pasta e a API em outra, diga quais são no
bloco `with:` do seu `.github/workflows/deploy.yml` (o mesmo das opções acima). Cada
pasta é construída como um app à parte (com ou sem `Dockerfile`), e o endereço
público é o do frontend:

```yaml
    with:
      frontend: frontend        # pasta do site
      port: 80                  # porta do frontend
      backend: backend          # pasta da API
      backend_port: 8080
      backend_health: /health   # rota da API que responde 200
      database: true            # se a API usa MySQL
```

O frontend alcança a API em `http://127.0.0.1:<backend_port>` (nos exemplos
`fullstack-*`, o `nginx.conf` do frontend repassa `/api` para `http://127.0.0.1:8080`).
`backend_memory` (padrão `512`) ajusta a memória da API.

**Senhas e chaves:** crie um secret `APP_ENV` com uma linha `NOME=valor` por
variável (como um arquivo `.env`); o app recebe cada uma como variável de ambiente.
A variável `SECRET_KEY` já vem pronta (para assinar tokens e sessões).

## Exemplos prontos

Copie o conteúdo de uma pasta para a raiz do seu repositório. Os exemplos
`fullstack-*` trazem o próprio `.github/workflows/deploy.yml`, já com as opções
certas: copie-o também, **no lugar** do arquivo do passo 1 (a pasta `.github`
fica oculta em alguns gerenciadores de arquivos).

| Pasta | O que é | Dockerfile |
|-------|---------|------------|
| [`exemplos/site`](exemplos/site) | página estática, só um `index.html` (o mais simples) | não |
| [`exemplos/php`](exemplos/php) | mural de recados em PHP + MySQL, sem framework | não |
| [`exemplos/go`](exemplos/go) | API JSON em Go, só com a biblioteca padrão | não |
| [`exemplos/api-java-mobile`](exemplos/api-java-mobile) | API REST em Spring Boot + MySQL para um app mobile, com documentação em `/docs` | não |
| [`exemplos/fullstack-java`](exemplos/fullstack-java) | React + Spring Boot + MySQL | só no frontend |
| [`exemplos/fullstack-javascript`](exemplos/fullstack-javascript) | React + Express + MySQL | só no frontend |
| [`exemplos/fullstack-typescript`](exemplos/fullstack-typescript) | React + Express/Prisma + MySQL | só no frontend |
| [`exemplos/fullstack-python`](exemplos/fullstack-python) | React + FastAPI + MySQL | só no frontend |

Nos `fullstack-*`, só o frontend tem `Dockerfile`: ele precisa de um nginx com
configuração própria (repassar `/api` para o backend), o que a detecção
automática não faz. Os backends e os apps de uma pasta só não precisam.

## Deu errado?

- **Erro no build:** aba **Actions**, no passo que falhou.
- **`Não encontrei um app na pasta`:** o pipeline procura o app na raiz do repositório.
  Se ele está em pastas (`frontend/`, `backend/`), veja
  [App em subpastas](#app-em-subpastas-frontend--backend).
- **`permission_denied: write_package`:** sobrou uma imagem de um repositório apagado com
  o mesmo nome. Apague-a em **github.com/<seu-usuário>?tab=packages**.
- **App não abre:** entre em `https://nomad.projetos.sapucaia.ifsul.edu.br/ui` com o seu
  `NOMAD_TOKEN` e veja os logs em **Jobs**. Causa mais comum: `port` diferente da porta do app.
- Se uma versão nova não funcionar, a anterior continua no ar.
