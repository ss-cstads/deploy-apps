# Modelos de Dockerfile

Pontos de partida para escrever o `Dockerfile` do seu app. Copie o da sua
linguagem para a pasta do app com o nome `Dockerfile` (e o `dockerignore.*`
correspondente com o nome `.dockerignore`) e ajuste.

| Arquivo | Para |
|---------|------|
| `Dockerfile.java` | Spring Boot (Maven) |
| `Dockerfile.nodejs` | Node.js |
| `Dockerfile.python` | Python |

Com `Dockerfile`, informe no `deploy.yml` a porta que o app escuta
([opção `port`](../../../README.md#opções)).
