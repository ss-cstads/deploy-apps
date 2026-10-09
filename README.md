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
| Java | `pom.xml` ([exemplo](exemplos/sem-dockerfile/fullstack-java/backend/pom.xml)) ou `build.gradle`, mais um `project.toml` que escolhe a versão do Java e deixa a JVM enxuta ([exemplo](exemplos/sem-dockerfile/fullstack-java/backend/project.toml)). Com ele, Spring Boot pede `memory: 320` no `with:`, e Quarkus, Micronaut ou Javalin cabem nos 256 MB padrão; sem ele, a JVM só sobe com `memory: 768`. Para um executável nativo (GraalVM), veja o exemplo [`java-graalvm`](exemplos/sem-dockerfile/java-graalvm) |
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
| `memory` | `256` | memória reservada para o app, em MB; ele pode usar até o **dobro** disso antes de ser derrubado. Reserve perto do que o app usa de fato (Java: no mínimo `320`, veja a tabela do passo 1) |
| `database` | `false` | `true` liga o app ao seu banco no MariaDB do cluster (compatível com MySQL: mesmos drivers e mesmo SQL); o app recebe `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD` e `DATABASE_URL` |

### App em subpastas (frontend + backend)

Se o repositório tem o site numa pasta e a API em outra, diga quais são no
bloco `with:` do seu `.github/workflows/deploy.yml` (o mesmo das opções acima). Cada
pasta é construída como um app à parte (com ou sem `Dockerfile`), e o endereço
público é o do frontend:

```yaml
    with:
      frontend: frontend        # pasta do site
      port: 80                  # porta do frontend
      memory: 16                # memória do frontend (um nginx usa de 3 a 8 MB)
      backend: backend          # pasta da API
      backend_port: 8080
      backend_health: /health   # rota da API que responde 200
      database: true            # se a API usa banco (MariaDB/MySQL)
```

O frontend alcança a API em `http://127.0.0.1:<backend_port>` (nos exemplos
`fullstack-*`, o `nginx.conf` do frontend repassa `/api` para `http://127.0.0.1:8080`).
Sem `Dockerfile`, as duas partes recebem a porta pela variável `PORT`: dê ao
frontend uma porta diferente da do backend (por exemplo `port: 3000`).
`backend_memory` (padrão `256`) ajusta a memória da API. A regra do cluster é
reservar **perto do que o app usa de fato** (o teto, que derruba o app, é sempre o dobro da reserva): um backend em Node.js ou
Python usa de 40 a 100 MB, então o padrão sobra; um backend Spring Boot precisa
de `backend_memory: 320` (veja a linha do Java na tabela do passo 1). O passo
**Logs do app** mostra `OOM Killed` quando falta memória.

### Banco de dados

Com `database: true`, o app usa um banco **MariaDB** que já existe no cluster:
cada namespace tem o seu banco e o seu usuário, criados junto com a sua conta. O
MariaDB é compatível com o MySQL, então os drivers, as bibliotecas e o SQL são
os mesmos (os exemplos "+ MySQL" funcionam sem mudança). O app recebe o acesso
pronto nas variáveis `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER` e `DB_PASSWORD`
(e em `DATABASE_URL`); não há senha para cadastrar.

- O servidor é compartilhado: cada usuário tem até 20 conexões abertas e 60
  segundos por consulta. Um pool pequeno (5 conexões) é suficiente.
- Você só enxerga o seu banco; não dá para criar outros.
- Cópia de segurança, restauração de um arquivo `.sql` e limpeza do banco são
  feitas pelo professor, no painel do cluster.
- O banco fica fora do seu app: publicar outra versão, ou outro app no mesmo
  namespace, encontra os mesmos dados.

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
**Não é preciso trocar nada antes de publicar:** nos exemplos, o texto que
aparece ao lado de `SECRET_KEY` no código é só um valor de reserva, usado quando
você roda o app na sua máquina (onde a variável não existe). No cluster a
variável sempre existe, e é a chave sorteada que vale. O mesmo vale para as
variáveis do banco (`DB_HOST`, `DB_PASSWORD`...) quando há `database: true`: a
senha é sorteada pelo pipeline e chega pronta. Veja nos exemplos:
[JavaScript](exemplos/sem-dockerfile/fullstack-javascript/backend/server.js#L18),
[TypeScript](exemplos/sem-dockerfile/fullstack-typescript/backend/src/server.ts#L12),
[Python](exemplos/sem-dockerfile/fullstack-python/backend/main.py#L21) e
[Java](exemplos/sem-dockerfile/fullstack-java/backend/src/main/resources/application.yml#L24).
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
| [`java-graalvm`](exemplos/sem-dockerfile/java-graalvm) | API JSON em Java puro, compilada em executável nativo (GraalVM): sobe com 64 MB |
| [`java-quarkus`](exemplos/sem-dockerfile/java-quarkus) | API JSON em Java com Quarkus |
| [`java-micronaut`](exemplos/sem-dockerfile/java-micronaut) | API JSON em Java com Micronaut |
| [`java-javalin`](exemplos/sem-dockerfile/java-javalin) | API JSON em Java com Javalin |
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
| [`java-graalvm`](exemplos/com-dockerfile/java-graalvm) | API JSON em Java puro, compilada em executável nativo (GraalVM): sobe com 64 MB |
| [`java-quarkus`](exemplos/com-dockerfile/java-quarkus) | API JSON em Java com Quarkus |
| [`java-micronaut`](exemplos/com-dockerfile/java-micronaut) | API JSON em Java com Micronaut |
| [`java-javalin`](exemplos/com-dockerfile/java-javalin) | API JSON em Java com Javalin |
| [`api-java-mobile`](exemplos/com-dockerfile/api-java-mobile) | API REST em Spring Boot + MySQL para um app mobile, com documentação em `/docs` |
| [`fullstack-java`](exemplos/com-dockerfile/fullstack-java) | React + Spring Boot + MySQL |
| [`fullstack-javascript`](exemplos/com-dockerfile/fullstack-javascript) | React + Express + MySQL |
| [`fullstack-typescript`](exemplos/com-dockerfile/fullstack-typescript) | React + Express/Prisma + MySQL |
| [`fullstack-python`](exemplos/com-dockerfile/fullstack-python) | React + FastAPI + MySQL |
| [`modelos`](exemplos/com-dockerfile/modelos) | modelos de `Dockerfile` para Java, Node.js e Python, para adaptar ao seu app |

## Deu errado?

Tudo se vê na aba **Actions** do seu repositório: clique na execução e depois no
passo que ficou vermelho.

- **Erro no build** (passos "Build..."): o log mostra o erro de compilação ou de
  instalação de dependências, como apareceria na sua máquina.
- **`Não encontrei um app na pasta`:** o pipeline procura o app na raiz do repositório.
  Se ele está em pastas (`frontend/`, `backend/`), veja
  [App em subpastas](#app-em-subpastas-frontend--backend).
- **`permission_denied: write_package`:** sobrou uma imagem de um repositório apagado com
  o mesmo nome. Apague-a em **github.com/<seu-usuário>?tab=packages**.
- **O deploy falhou ou o app não abre:** abra o passo **Logs do app**, o último da
  execução. Ele mostra, para cada parte (`web`, `api`), o estado no
  cluster e as últimas linhas que o app escreveu. As causas mais comuns:
  - `port` diferente da porta em que o app escuta;
  - a rota de `health` não responde 200;
  - falta de memória (o estado mostra `OOM Killed`): aumente `memory`;
  - o app sai logo ao iniciar: o erro está nas últimas linhas do log.
- **Ver os logs de agora, sem mudar nada:** aba **Actions** → **Deploy** →
  **Run workflow**. A execução refaz o deploy da mesma versão e termina com os
  logs atuais.
- Se uma versão nova não funcionar, a anterior continua no ar.
