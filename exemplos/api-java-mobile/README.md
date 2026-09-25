# Exemplo: API Java para um app mobile

API REST de tarefas (Spring Boot 4, Java 25, MySQL) para ser consumida por um app
Android, iOS, Flutter ou React Native. Sem Dockerfile. Copie o conteúdo desta pasta
para a raiz do seu repositório, cadastre o `NOMAD_TOKEN`
([passo 2](../../README.md#2-cadastre-o-seu-token)) e faça push.

**Endereço da API:** `https://<seu-namespace>.projetos.sapucaia.ifsul.edu.br`
**Documentação interativa:** `/docs` — lista as rotas e permite testá-las no navegador.

| Método | Rota | O que faz |
|--------|------|-----------|
| `GET` | `/api/tarefas` | lista as tarefas |
| `GET` | `/api/tarefas/{id}` | uma tarefa (404 se não existir) |
| `POST` | `/api/tarefas` | cria: `{"titulo": "...", "descricao": "..."}` |
| `PUT` | `/api/tarefas/{id}` | atualiza: `{"titulo": "...", "concluida": true}` |
| `DELETE` | `/api/tarefas/{id}` | remove |

No app mobile, a chamada é um HTTP comum. Em JavaScript (React Native):

```js
const API = 'https://<seu-namespace>.projetos.sapucaia.ifsul.edu.br';
const resp = await fetch(`${API}/api/tarefas`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ titulo: 'Comprar pão' }),
});
const tarefa = await resp.json();
```

A API usa HTTPS com certificado válido e aceita chamadas de qualquer origem (CORS), o
que atende apps nativos e híbridos. Ela não tem login: para dados pessoais, acrescente
autenticação antes de usar de verdade.

```
src/main/java/br/edu/ifsul/api/   código (entidade, repositório, controller)
src/main/resources/application.yml  banco (DB_*) e porta (PORT) vêm do cluster
project.toml                       versão do Java para o build (25)
.github/workflows/deploy.yml       pipeline: health /actuator/health, 768 MB, database: true
```
