job [[ template "job_name" . ]] {
  namespace   = [[ var "namespace" . | quote ]]
  datacenters = ["dc1"]
  type        = "service"

  # Sem canary: o volume e single-node-writer, a versao nova so monta os dados
  # depois que a antiga para.
  update {
    max_parallel     = 1
    auto_revert      = true
    min_healthy_time = "10s"
    healthy_deadline = "5m"
  }

  group "db" {
    count = 1

    network {
      mode = "bridge"
      port "mysql" {
        to = 3306
      }
    }

    # Nome fixo <namespace>-mysql: so o <namespace>-backend (pack api) pode
    # conectar.
    service {
      name = "[[ var "namespace" . ]]-mysql"
      port = "mysql"
      tags = ["student", [[ var "namespace" . | quote ]], "database"]

      connect {
        sidecar_service {
          proxy {
            local_service_port = 3306
            config {
              protocol = "tcp"
            }
          }
        }
      }

      check {
        name     = "MySQL ping"
        type     = "script"
        task     = "mysql"
        command  = "mysqladmin"
        args     = ["ping", "-h", "127.0.0.1", "--silent"]
        interval = "15s"
        timeout  = "5s"
      }
    }

    restart {
      attempts = 3
      interval = "5m"
      delay    = "15s"
      mode     = "fail"
    }

    # Volume persistente do aluno: os dados sobrevivem a redeploys e reinicios.
    volume "mysql" {
      type            = "host"
      source          = "[[ var "namespace" . ]]-mysql"
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }

    task "mysql" {
      driver = "docker"

      config {
        image = [[ var "image" . | quote ]]
        ports = ["mysql"]
        args  = [
          "--character-set-server=utf8mb4",
          "--collation-server=utf8mb4_unicode_ci",
        ]
      }

      volume_mount {
        volume      = "mysql"
        destination = "/var/lib/mysql"
      }

      resources {
        cpu    = [[ var "cpu" . ]]
        memory = [[ var "memory" . ]]
      }

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

      # Senhas no Vault (secret/students/<namespace>/app): db_root_password e
      # db_password. Banco e usuario so sao criados no primeiro start (volume vazio).
      template {
        data        = <<EOH
{{ with secret "secret/data/students/[[ var "namespace" . ]]/app" -}}
MYSQL_ROOT_PASSWORD={{ .Data.data.db_root_password }}
MYSQL_PASSWORD={{ .Data.data.db_password }}
{{ end -}}
MYSQL_DATABASE=[[ var "database" . ]]
MYSQL_USER=[[ var "user" . ]]
EOH
        destination = "secrets/mysql.env"
        env         = true
        change_mode = "restart"
      }
    }
  }
}
