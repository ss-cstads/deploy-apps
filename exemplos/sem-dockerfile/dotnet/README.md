# Exemplo: API de mensagens em C# (.NET)

API JSON em ASP.NET Core (minimal API), sem Dockerfile. Copie o conteúdo desta
pasta para a raiz do seu repositório, cadastre o `NOMAD_TOKEN`
([passo 2](../../../README.md#2-cadastre-o-seu-token)) e faça push.

| Método | Rota | O que faz |
|--------|------|-----------|
| `GET` | `/api/mensagens` | lista as mensagens |
| `POST` | `/api/mensagens` | cria uma mensagem: `{"texto": "olá"}` |

```bash
curl -X POST https://<seu-namespace>.projetos.sapucaia.ifsul.edu.br/api/mensagens \
  -H 'Content-Type: application/json' -d '{"texto": "olá"}'
```

As mensagens ficam em memória e somem quando o app reinicia. Para guardá-las, use
`database: true` no `deploy.yml` e grave no MySQL (veja o exemplo `php` ou `api-java-mobile`).

O pipeline reconhece o projeto pelo arquivo `.csproj` e usa a versão do .NET
pedida em `TargetFramework` (aqui, `net10.0`). O app não precisa ler a porta: o
pipeline já o sobe na porta informada pelo cluster.
