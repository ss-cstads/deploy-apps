# Exemplo: React + Spring Boot 3 + MySQL

App de tarefas com login. Para usar: copie o conteúdo desta pasta para a raiz
do seu repositório, cadastre o `NOMAD_TOKEN` ([passo 2](../../README.md#2-cadastre-o-seu-token))
e faça push.

```
.github/workflows/deploy.yml   pipeline (frontend + backend + banco)
frontend/                      React (Vite) servido pelo nginx, com Dockerfile (nginx.conf: /api -> backend)
backend/                       API REST, sem Dockerfile (pom.xml; project.toml ajusta a memória da JVM)
```

O backend recebe do cluster `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`,
`DB_PASSWORD`, `DATABASE_URL` e `SECRET_KEY` — não é preciso configurar senha.

Login inicial: `admin` / `admin123`.

Para mexer no frontend na sua máquina: `cd frontend && npm install && npm run dev`
(abre em http://localhost:5173; o Vite repassa `/api` para o backend em `localhost:8080`,
como o nginx faz no cluster).

**Memória do backend:** um app Java precisa de pelo menos 512 MB. O `deploy.yml`
deste exemplo já traz `backend_memory: 512` dentro do `with:`, e o
`backend/project.toml` faz a JVM caber nesse limite. Se o seu app crescer e o
backend não subir por falta de memória, troque para `backend_memory: 768`.
