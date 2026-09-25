# Nomad Packs — IFSul Sapucaia

Registry de [Nomad Pack](https://developer.hashicorp.com/nomad/tools/nomad-pack) usado
pelas pipelines dos alunos. Em vez de escrever o job HCL, o aluno escolhe um pack e
informa só o que muda entre aplicações (imagem, porta, recursos, segredos).

O que o pack já resolve — e o aluno não precisa (nem consegue) errar:

- nomes de serviço `<namespace>-app` / `-backend` / `-mysql`, que casam com as
  intentions do Consul e com a rota do Ingress Gateway;
- service mesh (Consul Connect), health check, restart/reschedule;
- deploy com canary e rollback automático;
- segredos do Vault via Workload Identity;
- volume persistente do MySQL.

## Packs

| Pack | Serviço | Acesso | Uso típico |
|------|---------|--------|------------|
| `web_app` | `<namespace>-app` | público: `https://<namespace>.projetos.sapucaia.ifsul.edu.br` | site, frontend, app monolítica |
| `api` | `<namespace>-backend` | só pelo `web_app` (`backend_upstream = true`) | API REST |
| `mysql` | `<namespace>-mysql` | só pela `api` (`mysql_upstream = true`) | banco com dados persistentes |

```
internet → HAProxy → Ingress Gateway → web_app ─(127.0.0.1:8080)→ api ─(127.0.0.1:3306)→ mysql
```

## Variáveis

Comuns a `web_app` e `api` (o CI injeta `namespace` e `image`):

| Variável | Padrão (web_app / api) | Descrição |
|----------|------------------------|-----------|
| `port` | `8080` | porta em que a aplicação escuta no container |
| `health_path` | `/` / `/health` | rota que responde 2xx quando está saudável |
| `cpu` | `200` / `300` | MHz reservados |
| `memory` | `256` / `512` | MB; o container é encerrado se passar disso |
| `count` | `1` | instâncias |
| `healthy_deadline` | `3m` / `5m` | prazo para ficar saudável antes do rollback |
| `env` | `{}` | variáveis de ambiente não secretas |
| `vault_secrets` | `[]` | chaves de `secret/students/<namespace>/app` → env em MAIÚSCULAS |
| `job_name` | `web` / `api` | nome do job no namespace |

Só no `web_app`: `backend_upstream` (liga o acesso à `api`) e `backend_local_port` (`8080`).
Só na `api`: `mysql_upstream` (liga o acesso ao `mysql`) e `mysql_local_port` (`3306`).

`mysql`: `image` (`mysql:8.4`), `database` (`app`), `user` (`app`), `cpu` (`500`),
`memory` (`512`). As senhas vêm do Vault — `db_root_password` e `db_password` — e o
banco/usuário só são criados no primeiro start, com o volume vazio.

## Uso na pipeline

```bash
nomad-pack registry add ifsul github.com/ss-cstads/nomad-packs --ref=v1.0.0
nomad-pack run web_app --registry=ifsul --ref=v1.0.0 \
  -f nomad-pack.hcl \
  --var namespace="$STUDENT_NAMESPACE" \
  --var image="ghcr.io/$GITHUB_REPOSITORY:$GITHUB_SHA"
```

`nomad-pack.hcl` no repositório do aluno (sem prefixo do pack):

```hcl
port        = 3000
health_path = "/health"
memory      = 384
env           = { NODE_ENV = "production" }
vault_secrets = ["api_key"]
```

## Desenvolvimento

```bash
# Renderizar sem enviar ao cluster
nomad-pack render packs/web_app --var namespace=aluno01 --var image=nginx:alpine

# Validar contra o cluster (VPN + env.sh do hashicorp-cluster)
nomad-pack render packs/api --var namespace=aluno01 --var image=x --to-dir /tmp/r
nomad job validate /tmp/r/api/api.nomad
```

Os três packs têm uma cópia idêntica de `templates/_helpers.tpl` — ao alterar um,
copie para os outros. Mudanças que quebram a interface pedem nova tag (`v2.0.0`): as
pipelines fixam `--ref`, então alunos só recebem a mudança ao atualizar a tag.
