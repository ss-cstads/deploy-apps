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
  description = "Banco MariaDB (compatível com MySQL) em 127.0.0.1:3306, com DB_* e DATABASE_URL"
  type        = bool
  default     = false
}

# O banco e o usuário do namespace no MariaDB compartilhado do cluster têm o nome
# do namespace, com "-" trocado por "_" (quem os cria é o painel do cluster)
locals {
  db = replace(var.namespace, "-", "_")
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
              for_each = var.database ? ["mariadb"] : []
              content {
                destination_name = upstreams.value
                local_bind_port  = 3306
              }
            }
          }
        }

        # Reserva do proxy da malha (Envoy). O padrão do Nomad é 250 MHz e 128 MB
        # por proxy; medido no cluster com carga, cada um usa de 18 a 25 MB e quase
        # nada de CPU. Regra do cluster: reserva perto do uso, teto no dobro.
        # A CPU é garantia mínima (o proxy usa mais se o nó estiver ocioso); a
        # memória é teto.
        sidecar_task {
          resources {
            cpu        = 50
            memory     = 32
            memory_max = 64
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

      # Memória elástica: `memory` é o que o cluster reserva para o app (e o que
      # conta para decidir quantos apps cabem); `memory_max`, o dobro, é o teto que
      # o derruba. O app pode passar da reserva enquanto o nó tiver memória livre.
      resources {
        cpu        = 200
        memory     = var.memory
        memory_max = var.memory * 2
      }

      # Porta em que o app deve escutar (convenção dos Buildpacks; apps com
      # Dockerfile próprio podem ignorar)
      env {
        PORT = var.port
        # JVM: o limite que o container enxerga agora é o teto (2 x a reserva), e a
        # JVM dimensionaria o heap por ele. Estas duas variáveis a fazem calcular a
        # memória pela RESERVA; o resto do teto fica de folga para picos.
        #   - imagens do pipeline (Buildpacks): metade do limite fica de fora da conta
        #   - imagens com Dockerfile: a JVM considera a reserva como a memória da máquina
        # Não afetam apps que não são Java.
        BPL_JVM_HEAD_ROOM = "50"
        JAVA_TOOL_OPTIONS = "-XX:MaxRAM=${var.memory}m"
      }

      # Os itens de nomad/jobs viram variáveis de ambiente (DB_ROOT_PASSWORD é
      # resto do MySQL por namespace, que não existe mais). Sem a variable (app
      # sem segredos), o arquivo fica vazio e o app sobe normal.
      template {
        data        = <<EOH
{{ if nomadVarExists "nomad/jobs" -}}
{{ with nomadVar "nomad/jobs" -}}
{{ range .Tuples }}{{ if ne .K "DB_ROOT_PASSWORD" }}{{ .K }}={{ .V }}
{{ end }}{{ end -}}
%{ if var.database ~}
DATABASE_URL=mysql://${local.db}:{{ .DB_PASSWORD }}@127.0.0.1:3306/${local.db}
%{ endif ~}
{{ end -}}
{{ end -}}
%{ if var.database ~}
DB_HOST=127.0.0.1
DB_PORT=3306
DB_NAME=${local.db}
DB_USER=${local.db}
%{ endif ~}
EOH
        destination = "secrets/app.env"
        env         = true
        change_mode = "restart"
      }
    }
  }
}
