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
| Node.js | `package.json` com o script `start` ([exemplo](exemplos/sem-dockerfile/fullstack-javascript/backend/package.json)); o app escuta em `process.env.PORT`. TypeScript: o script `build` compila antes ([exemplo](exemplos/sem-dockerfile/fullstack-typescript/backend/package.json)) |
| Python | `requirements.txt` ([exemplo](exemplos/sem-dockerfile/fullstack-python/backend/requirements.txt)) e um arquivo `Procfile` com o comando que sobe o app, como `web: gunicorn app:app --bind 0.0.0.0:$PORT` ([exemplo](exemplos/sem-dockerfile/fullstack-python/backend/Procfile)) |
| Java | `pom.xml` ([exemplo](exemplos/sem-dockerfile/fullstack-java/backend/pom.xml)) ou `build.gradle`, e **memória no `with:`**: `memory: 768`, ou `memory: 512` com um `project.toml` como [este](exemplos/sem-dockerfile/fullstack-java/backend/project.toml) (o padrão de 256 MB não basta para a JVM). Usa Java 21, a menos que o `project.toml` peça outra versão ([exemplo](exemplos/sem-dockerfile/api-java-mobile/project.toml)) |
| PHP | `index.php` na raiz ([exemplo](exemplos/sem-dockerfile/php/index.php)); extensões (MySQL etc.) em `.php.ini.d/` ([exemplo](exemplos/sem-dockerfile/php/.php.ini.d)) |
| Go | `go.mod` (até Go 1.26) ([exemplo](exemplos/sem-dockerfile/go/go.mod)) |
| Site estático | `index.html` na raiz ([exemplo](exemplos/sem-dockerfile/site/index.html)) |
| Site com build (React, Vite) | `package.json` com o script `build`, um `project.toml` que manda rodá-lo e um `nginx.conf` que serve a pasta gerada ([exemplo](exemplos/sem-dockerfile/fullstack-javascript/frontend)) |
| .NET | o arquivo `.csproj` ([exemplo](exemplos/sem-dockerfile/dotnet/exemplo.csproj)) |
| Ruby | `Gemfile` com `puma`, `Gemfile.lock` e `config.ru` ([exemplo](exemplos/sem-dockerfile/ruby)) |

Com `Dockerfile` ([modelos por linguagem](exemplos/com-dockerfile/modelos)), você controla a
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
Sem `Dockerfile`, as duas partes recebem a porta pela variável `PORT`: dê ao
frontend uma porta diferente da do backend (por exemplo `port: 3000`).
`backend_memory` (padrão `512`) ajusta a memória da API.

## Variáveis, senhas e chaves do app

Se o app precisa de valores que não podem ficar no código (senha de e-mail, chave
de uma API, token de um serviço), **não os escreva no repositório**: ele é
público, e qualquer pessoa leria. Em vez de um arquivo `.env` no repositório,
guarde o conteúdo dele num *secret* do GitHub:

1. No repositório: **Settings → Secrets and variables → Actions → New repository
   secret** (o mesmo lugar onde você cadastrou o `NOMAD_TOKEN`).
2. Em **Name**, escreva `APP_ENV`.
3. Em **Secret**, escreva uma variável por linha, no formato `NOME=valor`, como
   num arquivo `.env`:

   ```
   MAIL_PASSWORD=minha-senha-do-email
   API_KEY=abc123
   ```

   Sem espaços em volta do `=` (a linha é ignorada se houver) e sem aspas em volta do valor.
4. Faça um novo push (ou rode o pipeline de novo na aba **Actions**).

A partir daí o app recebe cada linha como uma variável de ambiente e lê do jeito
normal da linguagem: `process.env.API_KEY` (Node.js), `os.environ["API_KEY"]`
(Python), `System.getenv("API_KEY")` (Java), `getenv('API_KEY')` (PHP).

Para trocar um valor, edite o secret `APP_ENV` e faça outro push. O GitHub não
mostra o conteúdo antigo: escreva de novo todas as linhas. Uma variável que você
tirar do `APP_ENV` continua valendo com o último valor; para anulá-la, deixe a
linha com o valor vazio (`NOME=`).

### `SECRET_KEY`: uma chave que o cluster cria para você

Apps com login precisam de um texto secreto para **assinar** os tokens (JWT) ou
os cookies de sessão: é o que impede alguém de forjar um login. Você não precisa
inventar nem cadastrar esse texto. No primeiro deploy, o pipeline sorteia uma
chave aleatória para o seu namespace e a entrega ao app na variável de ambiente
`SECRET_KEY`; ela continua a mesma nos deploys seguintes, então os logins não
caem a cada push.

Basta o app ler essa variável onde configuraria o segredo do JWT ou da sessão.
Veja nos exemplos:
[JavaScript](exemplos/sem-dockerfile/fullstack-javascript/backend/server.js#L16),
[TypeScript](exemplos/sem-dockerfile/fullstack-typescript/backend/src/server.ts#L12),
[Python](exemplos/sem-dockerfile/fullstack-python/backend/main.py#L19) e
[Java](exemplos/sem-dockerfile/fullstack-java/backend/src/main/resources/application.yml#L21).
Se o app não tem login, ignore-a. Para usar uma chave sua, ponha uma linha
`SECRET_KEY=...` no `APP_ENV`.

## Exemplos prontos

Copie o conteúdo de uma pasta para a raiz do seu repositório, **inclusive o
`.github/workflows/deploy.yml` dela**, no lugar do arquivo do passo 1 (a pasta
`.github` fica oculta em alguns gerenciadores de arquivos).

Os mesmos apps aparecem em até três versões, conforme quem monta a imagem:

### Sem Dockerfile ([`exemplos/sem-dockerfile`](exemplos/sem-dockerfile))

O mais simples: o pipeline reconhece o projeto pelos arquivos e monta a imagem.

| Pasta | O que é |
|-------|---------|
| [`site`](exemplos/sem-dockerfile/site) | página estática, só um `index.html` |
| [`php`](exemplos/sem-dockerfile/php) | mural de recados em PHP + MySQL, sem framework |
| [`go`](exemplos/sem-dockerfile/go) | API JSON em Go, só com a biblioteca padrão |
| [`ruby`](exemplos/sem-dockerfile/ruby) | API JSON em Ruby (Sinatra) |
| [`dotnet`](exemplos/sem-dockerfile/dotnet) | API JSON em C# (ASP.NET Core) |
| [`api-java-mobile`](exemplos/sem-dockerfile/api-java-mobile) | API REST em Spring Boot + MySQL para um app mobile, com documentação em `/docs` |
| [`fullstack-java`](exemplos/sem-dockerfile/fullstack-java) | React + Spring Boot + MySQL |
| [`fullstack-javascript`](exemplos/sem-dockerfile/fullstack-javascript) | React + Express + MySQL |
| [`fullstack-typescript`](exemplos/sem-dockerfile/fullstack-typescript) | React + Express/Prisma + MySQL |
| [`fullstack-python`](exemplos/sem-dockerfile/fullstack-python) | React + FastAPI + MySQL |

### Dockerfile parcial ([`exemplos/dockerfile-parcial`](exemplos/dockerfile-parcial))

Só para apps com frontend e backend em pastas separadas: o frontend tem
`Dockerfile` (você controla o nginx) e o backend é reconhecido pelos arquivos.

| Pasta | O que é |
|-------|---------|
| [`fullstack-java`](exemplos/dockerfile-parcial/fullstack-java) | React + Spring Boot + MySQL |
| [`fullstack-javascript`](exemplos/dockerfile-parcial/fullstack-javascript) | React + Express + MySQL |
| [`fullstack-typescript`](exemplos/dockerfile-parcial/fullstack-typescript) | React + Express/Prisma + MySQL |
| [`fullstack-python`](exemplos/dockerfile-parcial/fullstack-python) | React + FastAPI + MySQL |

### Dockerfile completo ([`exemplos/com-dockerfile`](exemplos/com-dockerfile))

Todos os exemplos, cada parte com o seu `Dockerfile`: você escolhe a imagem
base, os pacotes e o comando de início.

| Pasta | O que é |
|-------|---------|
| [`site`](exemplos/com-dockerfile/site) | página estática, só um `index.html` |
| [`php`](exemplos/com-dockerfile/php) | mural de recados em PHP + MySQL, sem framework |
| [`go`](exemplos/com-dockerfile/go) | API JSON em Go, só com a biblioteca padrão |
| [`ruby`](exemplos/com-dockerfile/ruby) | API JSON em Ruby (Sinatra) |
| [`dotnet`](exemplos/com-dockerfile/dotnet) | API JSON em C# (ASP.NET Core) |
| [`api-java-mobile`](exemplos/com-dockerfile/api-java-mobile) | API REST em Spring Boot + MySQL para um app mobile, com documentação em `/docs` |
| [`fullstack-java`](exemplos/com-dockerfile/fullstack-java) | React + Spring Boot + MySQL |
| [`fullstack-javascript`](exemplos/com-dockerfile/fullstack-javascript) | React + Express + MySQL |
| [`fullstack-typescript`](exemplos/com-dockerfile/fullstack-typescript) | React + Express/Prisma + MySQL |
| [`fullstack-python`](exemplos/com-dockerfile/fullstack-python) | React + FastAPI + MySQL |
| [`modelos`](exemplos/com-dockerfile/modelos) | modelos de `Dockerfile` para Java, Node.js e Python, para adaptar ao seu app |

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
