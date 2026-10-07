# Exemplo: React + FastAPI + MySQL

App de tarefas com login. Para usar: copie o conteúdo desta pasta para a raiz
do seu repositório, cadastre o `NOMAD_TOKEN` ([passo 2](../../../README.md#2-cadastre-o-seu-token))
e faça push.

```
.github/workflows/deploy.yml   pipeline (frontend + backend + banco)
frontend/                      React (Vite) servido pelo nginx, sem Dockerfile (project.toml manda rodar o build; nginx.conf: /api -> backend)
backend/                       API REST, sem Dockerfile (requirements.txt + Procfile)
```

O backend recebe do cluster `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`,
`DB_PASSWORD`, `DATABASE_URL` e `SECRET_KEY` — não é preciso configurar senha.

Login inicial: `admin` / `admin123`.

Para mexer no frontend na sua máquina: `cd frontend && npm install && npm run dev`
(abre em http://localhost:5173; o Vite repassa `/api` para o backend em `localhost:8080`,
como o nginx faz no cluster).

**Sem Dockerfile em nenhuma das duas pastas.** O frontend escuta na porta 3000
(`port: 3000` no `deploy.yml`), porque a 8080 é do backend. O mesmo app existe
com `Dockerfile` só no frontend ([dockerfile-parcial](../../dockerfile-parcial/fullstack-python))
e nas duas pastas ([com-dockerfile](../../com-dockerfile/fullstack-python)).
