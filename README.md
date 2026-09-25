# Publicar seu app no ar

Coloque seu app em `https://<seu-namespace>.projetos.sapucaia.ifsul.edu.br` sem
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

**Não precisa de Dockerfile:** o pipeline reconhece o projeto pelos arquivos dele.

| Projeto | O que o repositório precisa ter |
|---------|--------------------------------|
| Node.js | `package.json` com o script `start`; o app escuta em `process.env.PORT` |
| Python | `requirements.txt` e um arquivo `Procfile`, por exemplo: `web: gunicorn app:app --bind 0.0.0.0:$PORT` |
| Java | `pom.xml` ou `build.gradle`; usa Java 21, a menos que um `project.toml` peça outra versão ([exemplo](exemplos/api-java-mobile/project.toml)) |
| PHP | `index.php` na raiz; extensões (MySQL etc.) em `.php.ini.d/` ([exemplo](exemplos/php)) |
| Go | `go.mod` (até Go 1.26) |
| Site estático | `index.html` na raiz |
| .NET, Ruby | os arquivos normais do projeto |

Se o repositório tiver um `Dockerfile`, ele é usado no lugar
([modelos por linguagem](exemplos/dockerfiles)). Nesse caso, informe a porta do app
no fim do arquivo acima:

```yaml
    with:
      port: 3000
```

## 2. Cadastre o seu token

No repositório: **Settings → Secrets and variables → Actions → New repository secret**.
Nome: `NOMAD_TOKEN`. Valor: o token da folha de credenciais que você recebeu.

## 3. Faça push

Acompanhe na aba **Actions**. Em cerca de 2 minutos o app está no ar. O repositório
precisa ser **público**.

## Opções

Dentro de `with:`:

| Opção | Padrão | Para que serve |
|-------|--------|----------------|
| `port` | `8080` | porta do app (sem Dockerfile, o app recebe a variável `PORT` com esse valor) |
| `health` | `/` | rota que responde 200 quando o app está funcionando |
| `memory` | `256` | memória em MB |
| `database` | `false` | `true` cria um MySQL; o app recebe `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD` e `DATABASE_URL` |

**Senhas e chaves:** crie um secret `APP_ENV` com uma linha `NOME=valor` por
variável (como um arquivo `.env`); o app recebe cada uma como variável de ambiente.
A variável `SECRET_KEY` já vem pronta (para assinar tokens e sessões).

## Exemplos prontos

Copie o conteúdo de uma pasta para a raiz do seu repositório:

| Pasta | O que é |
|-------|---------|
| [`exemplos/site`](exemplos/site) | página estática, só um `index.html` (o mais simples) |
| [`exemplos/php`](exemplos/php) | mural de recados em PHP + MySQL, sem framework |
| [`exemplos/go`](exemplos/go) | API JSON em Go, só com a biblioteca padrão |
| [`exemplos/api-java-mobile`](exemplos/api-java-mobile) | API REST em Spring Boot + MySQL para um app mobile, com documentação em `/docs` |
| [`exemplos/fullstack-java`](exemplos/fullstack-java) | Angular + Spring Boot + MySQL |
| [`exemplos/fullstack-javascript`](exemplos/fullstack-javascript) | Angular + Express + MySQL |
| [`exemplos/fullstack-typescript`](exemplos/fullstack-typescript) | Angular + Express/Prisma + MySQL |
| [`exemplos/fullstack-python`](exemplos/fullstack-python) | Angular + FastAPI + MySQL |

## Deu errado?

- **Erro no build:** aba **Actions**, no passo que falhou.
- **`permission_denied: write_package`:** sobrou uma imagem de um repositório apagado com
  o mesmo nome. Apague-a em **github.com/<seu-usuário>?tab=packages**.
- **App não abre:** entre em `https://nomad.projetos.sapucaia.ifsul.edu.br/ui` com o seu
  `NOMAD_TOKEN` e veja os logs em **Jobs**. Causa mais comum: `port` diferente da porta do app.
- Se uma versão nova não funcionar, a anterior continua no ar.
