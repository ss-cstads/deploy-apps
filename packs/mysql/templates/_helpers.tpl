[[- /*
Helpers comuns aos packs (web_app, api, mysql). Os tres packs tem uma copia
identica deste arquivo: packs nao compartilham templates sem uma dependencia.
*/ -]]

[[- define "job_name" -]]
[[ coalesce (var "job_name" .) (meta "pack.name" .) | quote ]]
[[- end -]]

[[- /* Canary com promocao e rollback automaticos: deploy com falha volta sozinho. */ -]]
[[ define "update" -]]
  update {
    max_parallel     = 1
    canary           = 1
    auto_promote     = true
    auto_revert      = true
    min_healthy_time = "10s"
    healthy_deadline = [[ var "healthy_deadline" . | quote ]]
  }
[[- end -]]

[[ define "restart_reschedule" -]]
    restart {
      attempts = 3
      interval = "5m"
      delay    = "15s"
      mode     = "fail"
    }

    reschedule {
      attempts       = 3
      interval       = "30m"
      delay          = "15s"
      delay_function = "exponential"
      max_delay      = "2m"
      unlimited      = false
    }
[[- end -]]

[[- /* Upstream <namespace>-mysql em 127.0.0.1:3306 (dentro de proxy {}). */ -]]
[[ define "mysql_upstream" -]]
[[- if var "mysql_upstream" . ]]

            # <namespace>-mysql (pack mysql) em 127.0.0.1:3306
            upstreams {
              destination_name = "[[ var "namespace" . ]]-mysql"
              local_bind_port  = 3306
            }
[[- end ]]
[[- end -]]

[[- /*
Segredos do app: todos os itens da Nomad Variable nomad/jobs do namespace
viram variaveis de ambiente (o pipeline grava ali os secrets APP_* do GitHub,
DB_PASSWORD e SECRET_KEY). Com mysql_upstream, tambem as variaveis de conexao.
Sem a variable (app sem segredos), o template fica vazio e o app sobe normal.
*/ -]]
[[ define "app_env" -]]
      template {
        data        = <<EOH
{{ if nomadVarExists "nomad/jobs" -}}
{{ with nomadVar "nomad/jobs" -}}
{{ range .Tuples }}{{ .K }}={{ .V }}
{{ end -}}
[[- if var "mysql_upstream" . ]]
DATABASE_URL=mysql://app:{{ .DB_PASSWORD }}@127.0.0.1:3306/app
[[- end ]]
{{ end -}}
{{ end -}}
[[- if var "mysql_upstream" . ]]
DB_HOST=127.0.0.1
DB_PORT=3306
DB_NAME=app
DB_USER=app
[[- end ]]
EOH
        destination = "secrets/app.env"
        env         = true
        change_mode = "restart"
      }
[[- end -]]
