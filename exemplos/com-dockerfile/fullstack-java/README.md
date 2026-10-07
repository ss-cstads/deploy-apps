# Exemplo: React + Spring Boot 3 + MySQL

App de tarefas com login. Para usar: copie o conteúdo desta pasta para a raiz
do seu repositório, cadastre o `NOMAD_TOKEN` ([passo 2](../../../README.md#2-cadastre-o-seu-token))
e faça push.

```
.github/workflows/deploy.yml   pipeline (frontend + backend + banco)
frontend/                      React (Vite) servido pelo nginx, com Dockerfile (nginx.conf: /api -> backend)
backend/                       API REST, com Dockerfile
```

O backend recebe do cluster `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`,
`DB_PASSWORD`, `DATABASE_URL` e `SECRET_KEY` — não é preciso configurar senha.

Login inicial: `admin` / `admin123`.

Para mexer no frontend na sua máquina: `cd frontend && npm install && npm run dev`
(abre em http://localhost:5173; o Vite repassa `/api` para o backend em `localhost:8080`,
como o nginx faz no cluster).

**Memória do backend:** um app Java precisa de pelo menos 512 MB; o `deploy.yml`
deste exemplo já traz `backend_memory: 512` dentro do `with:`.

**Com Dockerfile nas duas pastas:** você escolhe a imagem base, o usuário que
roda o app e o comando de início. A porta que cada parte escuta tem de ser a do
`deploy.yml` (`port` para o frontend, `backend_port` para o backend). O mesmo
app existe sem nenhum `Dockerfile` ([sem-dockerfile](../../sem-dockerfile/fullstack-java)).
