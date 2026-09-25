# Exemplo: Angular + Express + TypeScript + Prisma + MySQL

App de tarefas com login. Para usar: copie o conteúdo desta pasta para a raiz
do seu repositório, cadastre o `NOMAD_TOKEN` ([passo 2](../../README.md#2-cadastre-o-seu-token))
e faça push.

```
.github/workflows/deploy.yml   pipeline (frontend + backend + banco)
frontend/                      Angular servido pelo nginx (nginx.conf: /api -> backend)
backend/                       API REST
```

O backend recebe do cluster `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`,
`DB_PASSWORD`, `DATABASE_URL` e `SECRET_KEY` — não é preciso configurar senha.

Login inicial: `admin` / `admin123`.
