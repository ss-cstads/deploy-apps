# Exemplo: mural de recados em PHP + MySQL

Página onde qualquer pessoa deixa um recado, gravado num banco MySQL. PHP puro,
sem framework e sem Dockerfile. Copie o conteúdo desta pasta para a raiz do seu
repositório, cadastre o `NOMAD_TOKEN` ([passo 2](../../README.md#2-cadastre-o-seu-token))
e faça push.

```
index.php                      a página (lê e grava os recados)
.php.ini.d/extensoes.ini       liga as extensões do PHP (MySQL e texto com acento)
.github/workflows/deploy.yml   pipeline, com database: true
```

A conexão com o banco vem pronta do cluster nas variáveis `DB_HOST`, `DB_PORT`,
`DB_NAME`, `DB_USER` e `DB_PASSWORD`; a tabela é criada no primeiro acesso.
