# Exemplo: API de mensagens em Ruby

API JSON em Ruby com Sinatra, sem Dockerfile. Copie o conteúdo desta
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

O pipeline reconhece o projeto pelo `Gemfile` e sobe o app com o Puma, por isso
`puma` precisa estar no `Gemfile` e o `config.ru` precisa existir. O
`Gemfile.lock` também vai para o repositório: depois de mexer no `Gemfile`, rode
`bundle lock --add-platform x86_64-linux` e faça commit dos dois.
