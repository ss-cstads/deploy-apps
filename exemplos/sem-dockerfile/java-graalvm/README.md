# Exemplo: API de mensagens em Java nativo (GraalVM)

API JSON em Java puro, só com a biblioteca padrão, compilada pelo GraalVM em **executável nativo**: não há JVM ao rodar, o app sobe em milissegundos e usa poucos MB de memória. Sem Dockerfile. Copie o conteúdo desta
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

O `project.toml` pede o executável nativo (`BP_NATIVE_IMAGE`). O build demora
mais que o de um app Java comum (alguns minutos), porque o GraalVM analisa o
programa inteiro. Funciona sem ajuste porque o código não usa reflexão; com
frameworks, o caminho é o Quarkus ou o Micronaut, que já trazem o que o
compilador nativo precisa.
