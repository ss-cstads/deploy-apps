[[- /*
Helpers comuns aos packs do cluster IFSul (web_app, api, mysql).
Os tres packs tem uma copia identica deste arquivo: packs nao compartilham
templates sem uma dependencia, e uma copia e mais simples de ler.
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

[[- /*
Segredos do Vault (KV secret/students/<namespace>/app) como variaveis de
ambiente, de duas formas:
  vault_secrets: cada chave vira uma variavel em maiusculas (db_password -> DB_PASSWORD)
  secret_env:    variavel = texto com {{chave}} substituido pelo segredo
                 (DATABASE_URL = "mysql://app:{{db_password}}@127.0.0.1:3306/app")
Sem nenhum dos dois, nenhum bloco de Vault e gerado.
*/ -]]
[[ define "vault_secrets" -]]
[[- if or (var "vault_secrets" .) (var "secret_env" .) ]]
      identity {
        name        = "vault_default"
        aud         = ["vault.io"]
        ttl         = "1h"
        env         = true
        file        = true
        change_mode = "restart"
      }

      vault {
        role = "student-[[ var "namespace" . ]]-role"
      }

      template {
        data        = <<EOH
{{ with secret "secret/data/students/[[ var "namespace" . ]]/app" -}}
[[- range $key := var "vault_secrets" . ]]
[[ $key | upper ]]={{ index .Data.data "[[ $key ]]" }}
[[- end ]]
[[- range $name, $value := var "secret_env" . ]]
[[ $name ]]=[[ regexReplaceAll "\\{\\{\\s*([A-Za-z0-9_]+)\\s*\\}\\}" $value "{{ index .Data.data \"${1}\" }}" ]]
[[- end ]]
{{ end -}}
EOH
        destination = "secrets/vault.env"
        env         = true
        change_mode = "restart"
      }
[[- end ]]
[[- end -]]

[[ define "env" -]]
[[- if var "env" . ]]
      env {
[[- range $k, $v := var "env" . ]]
        [[ $k ]] = [[ $v | quote ]]
[[- end ]]
      }
[[- end ]]
[[- end -]]
