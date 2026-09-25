# MySQL do aluno (usado pelo pipeline quando database: true). Serviço
# <namespace>-mysql; dados no volume <namespace>-mysql.

variable "namespace" {
  type = string
}

job "mysql" {
  namespace   = var.namespace
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
      name = "${var.namespace}-mysql"
      port = "mysql"
      tags = ["student", var.namespace, "database"]

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
      source          = "${var.namespace}-mysql"
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }

    task "mysql" {
      driver = "docker"

      config {
        image = "mysql:8.4"
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
        cpu    = 500
        memory = 512
      }

      # Senhas geradas pelo pipeline no primeiro deploy (Nomad Variable
      # nomad/jobs). Banco e usuario "app" so sao criados com o volume vazio.
      template {
        data        = <<EOH
{{ with nomadVar "nomad/jobs" -}}
MYSQL_ROOT_PASSWORD={{ .DB_ROOT_PASSWORD }}
MYSQL_PASSWORD={{ .DB_PASSWORD }}
{{ end -}}
MYSQL_DATABASE=app
MYSQL_USER=app
EOH
        destination = "secrets/mysql.env"
        env         = true
        change_mode = "restart"
      }
    }
  }
}
