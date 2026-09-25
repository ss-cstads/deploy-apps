# App do aluno (usado pelo pipeline .github/workflows/deploy.yml).
#   job "web", serviço <namespace>-app:     público em https://<namespace>.projetos...
#   job "api", serviço <namespace>-backend: só o <namespace>-app chama
# O rótulo do job não aceita variável: o pipeline troca o ID ("web"/"api") no JSON.
# Segredos: Nomad Variable nomad/jobs do namespace (gravada pelo pipeline).

variable "namespace" {
  type = string
}

variable "service" {
  type    = string
  default = "app"
}

variable "image" {
  type = string
}

variable "port" {
  type    = number
  default = 8080
}

variable "health" {
  type    = string
  default = "/"
}

variable "memory" {
  type    = number
  default = 256
}

variable "backend" {
  description = "Backend em 127.0.0.1:8080"
  type        = bool
  default     = false
}

variable "database" {
  description = "MySQL em 127.0.0.1:3306, com DB_* e DATABASE_URL"
  type        = bool
  default     = false
}

job "app" {
  namespace   = var.namespace
  datacenters = ["dc1"]
  type        = "service"

  # Canary com rollback automático: versão que não fica saudável é descartada
  update {
    max_parallel     = 1
    canary           = 1
    auto_promote     = true
    auto_revert      = true
    min_healthy_time = "10s"
    healthy_deadline = "5m"
  }

  group "app" {
    network {
      mode = "bridge"
      port "http" {
        to = var.port
      }
    }

    service {
      name = "${var.namespace}-${var.service}"
      port = "http"
      tags = ["student", var.namespace]

      connect {
        sidecar_service {
          proxy {
            local_service_port = var.port
            config {
              protocol = "http"
            }

            dynamic "upstreams" {
              for_each = var.backend ? ["${var.namespace}-backend"] : []
              content {
                destination_name = upstreams.value
                local_bind_port  = 8080
              }
            }

            dynamic "upstreams" {
              for_each = var.database ? ["${var.namespace}-mysql"] : []
              content {
                destination_name = upstreams.value
                local_bind_port  = 3306
              }
            }
          }
        }
      }

      check {
        type     = "http"
        path     = var.health
        interval = "10s"
        timeout  = "3s"
      }
    }

    restart {
      attempts = 3
      interval = "5m"
      delay    = "15s"
      mode     = "fail"
    }

    task "app" {
      driver = "docker"

      config {
        image = var.image
        ports = ["http"]
      }

      resources {
        cpu    = 200
        memory = var.memory
      }

      # Os itens de nomad/jobs viram variáveis de ambiente (menos a senha root
      # do MySQL, que só o mysql.nomad.hcl usa). Sem a variable (app sem
      # segredos), o arquivo fica vazio e o app sobe normal.
      template {
        data        = <<EOH
{{ if nomadVarExists "nomad/jobs" -}}
{{ with nomadVar "nomad/jobs" -}}
{{ range .Tuples }}{{ if ne .K "DB_ROOT_PASSWORD" }}{{ .K }}={{ .V }}
{{ end }}{{ end -}}
%{ if var.database ~}
DATABASE_URL=mysql://app:{{ .DB_PASSWORD }}@127.0.0.1:3306/app
%{ endif ~}
{{ end -}}
{{ end -}}
%{ if var.database ~}
DB_HOST=127.0.0.1
DB_PORT=3306
DB_NAME=app
DB_USER=app
%{ endif ~}
EOH
        destination = "secrets/app.env"
        env         = true
        change_mode = "restart"
      }
    }
  }
}
