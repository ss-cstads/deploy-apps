# Exemplo: API de mensagens em Java com Micronaut

API JSON em Java com o Micronaut, rodando na JVM. O Micronaut gera o código das rotas e do JSON na compilação, sem reflexão. Sem Dockerfile. Copie o conteúdo desta
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
`database: true` no `deploy.yml` e grave no MySQL (veja o exemplo `api-java-mobile`).

O `project.toml` pede o Java 25 e deixa a JVM enxuta (coletor de lixo serial,
menos threads, menos memória reservada), para o app caber nos 256 MB padrão.
Sem ele o app não sobe com menos de ~700 MB.
