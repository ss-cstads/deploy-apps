# Exemplo: API de mensagens em Java nativo (GraalVM)

API JSON em Java puro, só com a biblioteca padrão, compilada pelo GraalVM em **executável nativo**: não há JVM ao rodar, o app sobe em milissegundos e usa poucos MB de memória. Com `Dockerfile`. Copie o conteúdo desta
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

O `Dockerfile` compila o código com o GraalVM num executável estático e a
imagem final tem só esse arquivo: sem JVM e sem sistema operacional. O build
demora alguns minutos, porque o GraalVM analisa o programa inteiro.
